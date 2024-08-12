library ieee;
use ieee.std_logic_1164.all;

entity UART_RX is
generic
(
	DATA_WIDTH : integer
);
port
(
	clk		 		: in std_logic;
	rst		 		: in std_logic;
	
	RS232_RX 		: in std_logic;
	RS232_DATA 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
	RS232_IRQ		: out std_logic; -- Shows the arrival of new data and that old data has been sucessfully arived
	RS232_IRQ_CLEAR : in std_logic	-- with IRQ signal there is always and IRQ clear signal


);
end entity;

architecture rtl of UART_RX is 

	component BaudClockGenerator is
	generic
	(
			NUMBER_OF_CLK_PULSE : integer;		-- based on size of data packet that is required to be txd (not same as clock)
			CLK_FREQ			: integer;		-- CLK_FREQ = clk but we define it seperately to do the calculation for bit-period and baud-rate
			BAUD_RATE			: integer;
			IS_UART_RX			: boolean 
	);
	port(
			clk			: in std_logic;  -- should be same as CLK_FREQ. 
			rst			: in std_logic;		
			
			start		: in std_logic;
			ready		: out std_logic;
			baud_clock	: out std_logic

	);
	end component;
	
	
	
	component ShiftRegister is
	generic
	(
		CHAIN_LENGTH 	: integer

	);
	port
	(
		clk				: in std_logic;
		rst				: in std_logic;
		
		Shift_Enable	: in std_logic;
		Din				: in std_logic;
		Dout			: out std_logic_vector(CHAIN_LENGTH-1 downto 0)


	);
	end component;
	
	
	
	
	
	component Synchronizer is
	port
	(
		clk		: in std_logic;
		rst		: in std_logic;
		
		Async	: in std_logic;
		Sync	: out std_logic

	);
	end component;
-------------------------------------------------

signal RS232_RX_sync 		 : std_logic; -- UART_RX own signal
signal RS232_RX_sync_delayed : std_logic;
signal falling_edge_detected : std_logic;

signal start		 : std_logic;
signal ready		 : std_logic;
signal baud_clock	 : std_logic;


type  SMDataType is (IDEAL, COLLECT_RS232_DATA, ASSERT_IRQ);

signal stateVariable : SMDataType;


begin 

	BaudClockGenerator_module: BaudClockGenerator 
	generic map
	(
			NUMBER_OF_CLK_PULSE => DATA_WIDTH + 1,	-- including start bit + DATA_WIDTH
			CLK_FREQ			=> 50000000,		-- CLK_FREQ = clk but we define it seperately to do the calculation for bit-period and baud-rate
			BAUD_RATE			=> 115200,
			IS_UART_RX			=> true 
	)
	port map
	(
			clk			=> clk,  -- should be same as CLK_FREQ. 
			rst			=> rst,	
			
			start		=> start,
			ready		=> ready,
			baud_clock	=> baud_clock

	);
	
	
	
	
	
	Synchronizer_module: Synchronizer 
	port map
	(
		clk		=> clk,
		rst		=> rst,
		
		Async	=> RS232_RX, -- Asynchronus to baud clock
		Sync	=> RS232_RX_sync --  synchronus to baud clock

	);
	
	
	
	
	
	
	ShiftRegister_module: ShiftRegister 
	generic map
	(
		CHAIN_LENGTH 	=> DATA_WIDTH

	)
	port map
	(
		clk				=> clk,
		rst				=> rst,
		
		Shift_Enable	=> baud_clock,
		Din				=> RS232_RX_sync, -- synchronized RS232 data goes into shift reg
		Dout			=> RS232_DATA


	);
	
	
	
	
	
	
----------------------------------------------------------------
-- Instantion completed, Now begins UART_RX discription
----------------------------------------------------------------

-- Discription: Ideal state of RS232_DATA = '1', start bit  = '0', therefore we detect the falling edge to start the baud clk
	StartBitDetection_Process : process (clk, rst) 
	begin
		if rst = '0' then
			RS232_RX_sync_delayed <= '1';	
			falling_edge_detected <= '0';			
		elsif rising_edge(clk) then
			RS232_RX_sync_delayed <= RS232_RX_sync;
			if RS232_RX_sync_delayed = '1' and RS232_RX_sync = '0' then
				falling_edge_detected <= '1';
			else 
				falling_edge_detected <= '0';
			end if;		
		end if;	
	end process;
	
	
	
	
	
	UART_RX_Process : process (clk, rst) 
	begin
		if rst = '0' then
			start <= '0';
			stateVariable <= IDEAL;
			RS232_IRQ <= '0';		
		elsif rising_edge(clk) then
			case(stateVariable) is
				when IDEAL =>
					if falling_edge_detected = '1' then
						start <= '1'; -- initiated baudclk
					else 
						start <= '0'; -- if we don't define else statement, start will hold '1' always						
					end if;
					-- as ready is one clock cycle delayed, we only move to next state when ready is already '0'.
					if ready = '0'  then -- ready signal tells the status of incoming data and completion of data reception.
						stateVariable <= COLLECT_RS232_DATA;
					end if;
				when COLLECT_RS232_DATA =>
					start <= '0'; -- deassert start signal to not make a mistake of restarting baud clk on every rising edge of clk.
					if ready = '1'  then -- ready signal tells the status of completion of data reception.
						stateVariable <= ASSERT_IRQ;
					end if;
				when ASSERT_IRQ =>
					RS232_IRQ <= '1';	-- Shows we have completed receiving data and are ready to receive next packet.
					stateVariable <= IDEAL; -- So, we now jump to ideal state again
				when others =>
					stateVariable <= IDEAL;
			end case;
			
			if RS232_IRQ_CLEAR = '1' then -- If we give this input
				RS232_IRQ <= '0';
			end if;
				
				
		end if;	
	end process;




end rtl;