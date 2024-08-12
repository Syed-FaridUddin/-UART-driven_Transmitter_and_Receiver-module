library ieee;
use ieee.std_logic_1164.all;

entity UART_TX is
generic
(
	RS232_DATA_BITS : integer;
	CLK_FREQ		: integer;
	BAUD_RATE		: integer
	

);
port
(

	clk					: in std_logic; -- 50MHz
	rst					: in std_logic; -- Logic 0 triggering
	
	Tx_Start			: in std_logic;
	Tx_Data				: in std_logic_vector(RS232_DATA_BITS-1 downto 0); -- Only Data bits 
	UART_Tx_Pin			: out std_logic;	-- Data transmitting pin
	Tx_ready			: out std_logic		-- Status bit (UART Tx is trasnmitting/ ideal)

);
end entity;

architecture rtl of UART_TX is

	-- Baud Clock generator of UART_TX
	component BaudClockGenerator 
	generic
	(
			NUMBER_OF_CLK_PULSE : integer;		-- based on size of data packet that is required to be txd (not same as clock)
			CLK_FREQ			: integer;
			BAUD_RATE			: integer;
			IS_UART_RX			: boolean 
	);
	port(
			clk			: in std_logic;
			rst			: in std_logic;		
			
			start		: in std_logic;
			ready		: out std_logic;
			baud_clock	: out std_logic

	);
	end component;
	
	
	-- Serial Data transmitter of UART_TX
	component Serializer 
	generic
	(

		DATA_WIDTH		: integer;
		DEFAULT_VALUE 	: std_logic

	);
	port
	(

		clk				: in std_logic;
		rst				: in std_logic;

		Shift_Enable	: in std_logic;
		Load			: in std_logic;
		Din				: in std_logic_vector(DATA_WIDTH-1 downto 0);
		Dout			: out std_logic

	);
	end component;
---------------------------------------------------------------------------------------

	signal txDataPacket 	: std_logic_vector(RS232_DATA_BITS+1 downto 0 );
	signal baud_clock 		: std_logic;
	
---------------------------------------------------------------------------------------

begin
	
	-- RS232 protocol trasmits LSB first.
	-- LSB is leftmost bit and MSB is the rightmost bit.
	-- Start bit is '0' and Stop bit is '1'.
	
	txDataPacket <= '1' & Tx_Data & '0' ;
	
	--------------------------------------------------------------------------------------
	
	UART_BaudClockGenerator : BaudClockGenerator 
	generic map
	(
			NUMBER_OF_CLK_PULSE =>	RS232_DATA_BITS + 2 ,	-- #clk pulse = #bits to be transmitted
			CLK_FREQ			=>	CLK_FREQ,
			BAUD_RATE			=>	BAUD_RATE,
			IS_UART_RX			=>  false 
	)
	port map
	(
			clk			=> clk,
			rst			=> rst,	
			
			start		=> Tx_Start,	-- When we insert Tx_Start, we start generating baud clock from the next rising edge of the clock
			ready		=> Tx_ready,
			baud_clock	=> baud_clock

	);
	
	-------------------------------------------------------------------------------------
	-- Serial Data transmitter of UART_TX
	UART_Serializer: Serializer 
	generic map
	(

		DATA_WIDTH		=> RS232_DATA_BITS + 2,
		DEFAULT_VALUE 	=> '1' -- Default value of RS232 protocol for transmission is '1' (ideal value)

	)
	port map
	(

		clk				=> clk,
		rst				=> rst,

		Shift_Enable	=> baud_clock,	-- Baud clock is the shift enable signal
		Load			=> Tx_Start,	-- When Tx_Start is insterted, we load our data in the UART_Serializer to be transmitted.
		Din				=> txDataPacket,
		Dout			=> UART_Tx_Pin

	);
	--------------------------------------------------------------------------------------


end rtl;
