library ieee;
use ieee.std_logic_1164.all;

entity TopLevelModule is
generic
(	-- With generic defined in main module, we don't have to define them in test bench.
	RS232_DATA_BITS	: integer := 8;
	CLK_FREQ		: integer := 50000000; --50MHz
	BAUD_RATE		: integer := 115200
);
port
(
	clk 			: in std_logic;
	rst 			: in std_logic;
	
	RS232_Tx_Pin 	: out std_logic; -- transmits data bit by bit
	RS232_Rx_Pin 	: in std_logic -- receives data bit by bit

);
end entity;

architecture rtl of TopLevelModule is

	-- Component call 
	Component UART_TX is
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
	end Component;
	
	Component UART_RX is
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
	end Component;
	
	type SM_DataType is (IDEAL, START_TRANSMISSION);
	signal SMvariable : SM_DataType;
	
	-- UART_Tx_ singals
	signal 	Tx_Start		:  std_logic;
	signal	RS232_Data		:  std_logic_vector(RS232_DATA_BITS-1 downto 0);  	
	signal	Tx_ready		:  std_logic;
	
	
	-- UART_RX singals
	signal	RS232_IRQ		:  std_logic;	
	
	
	
	

begin 

	-- Instantion of Component
	RS232_Tx: UART_TX 
	generic map
	(
		RS232_DATA_BITS => RS232_DATA_BITS, 
		CLK_FREQ		=> CLK_FREQ, 
		BAUD_RATE		=> BAUD_RATE 
		

	)
	port map
	(

		clk					=> clk, 
		rst					=> rst,
		
		Tx_Start			=> Tx_Start,
		Tx_Data				=> RS232_Data,  -- (1).. is the same data the tx echos back to the PC
		UART_Tx_Pin			=> RS232_Tx_Pin,	
		Tx_ready			=> Tx_ready	

	);
	-- UART_RX constantly checks for any data to receive.
	-- We don't have to enable any signal for rx to start receiving.
	-- The rx constantly monitors the channel line for the first start bit.
	-- this is acheived by looking for the falling edge constituted with the start bit.
	-- [ Note Ideal tx is '1', start bit = '0'. ]
	RS232_Rx: UART_RX 
	generic map
	(
		DATA_WIDTH => RS232_DATA_BITS	
	)
	port map
	(
		clk		 		=> clk, 
		rst		 		=> rst, 
		
		RS232_RX 		=> RS232_Rx_Pin, 
		RS232_DATA 		=> RS232_Data, -- whatever data(vector) rx collects from the PC..(1)
		RS232_IRQ		=> RS232_IRQ,  
		RS232_IRQ_CLEAR => Tx_Start 	
	);
	
	
	RS232_Module : process (rst, clk)
	begin
		if rst = '0' then
			-- All the signals and states initilized under this block is reseted here. 
			SMvariable <= IDEAL;
			Tx_Start <= '0'; 
		
		elsif rising_edge(clk) then
			case (SMvariable) is
				when IDEAL =>
					if RS232_IRQ = '1' and Tx_ready = '1' then
						Tx_Start <= '1';
						SMvariable <= START_TRANSMISSION;
					end if;	
					-- We constantly monitors rx and tx.
					-- If rx has successfully received data "AND"
					-- Tx is ready to start echoing back data to PC/ start transmission					
					-- if RS232_IRQ = '1' and Tx_ready = '1' then
						-- Tx_Start <= '1';
					-- end if;	
					-- if Tx_ready = '0' then						
						-- SMvariable <= START_TRANSMISSION;					
					-- end if;
					
				when START_TRANSMISSION =>
					Tx_Start <= '0';
					SMvariable <= IDEAL;
					
					-- Tx_Start <= '0';
					-- Start signal is generated after RS232_IRQ = '1'
					-- We can use it to deassert/clear RS232_IRQ.
					-- As here we only monitor completion of transmission.
					-- So we only check if Tx_ready = '1'
					-- Tx_ready = '1' shows successful transmission.
					-- if Tx_ready = '1' then
						-- SMvariable <= IDEAL; 
					-- end if;				
					
				when others =>
					SMvariable <= IDEAL;			
			end case;		
		end if;	
	end process;



end rtl;