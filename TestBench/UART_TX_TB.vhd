library ieee;
use ieee.std_logic_1164.all;

entity UART_TX_TB is 
	generic
	(
		RS232_DATA_BITS	: integer:= 8;
		CLK_FREQ		: integer:= 50000000; -- has to be same as "clk" freq.
		BAUD_RATE		: integer:= 115200

	);
end entity;

architecture rtl of UART_TX_TB is

	component UART_TX is
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
	end component;
-------------------------------------------------------------------------

	signal 	clk					:  std_logic:= '0'; -- 50MHz
	signal	rst					:  std_logic; -- Logic 0 triggering
			
	signal	Tx_Start			:  std_logic;
	signal	Tx_Data				:  std_logic_vector(RS232_DATA_BITS-1 downto 0); -- Only Data bits 
	signal	UART_Tx_Pin			:  std_logic;	-- Data transmitting pin
	signal	Tx_ready			:  std_logic;	-- Status bit (UART Tx is trasnmitting/ ideal)

-----------------------------------------------------------------------------------------------------


begin
	

	clk <= not clk after 10ns; -- 10ns is based off of 50MHz CLK_FREQ we have initilized there.
	
	---------------------------------------------------------------------------------------------
	
	
	UUT: UART_TX 
	generic map
	(
		RS232_DATA_BITS => RS232_DATA_BITS,
		CLK_FREQ		=> CLK_FREQ,
		BAUD_RATE		=> BAUD_RATE
		

	)
	port map
	(

		clk					=> clk, -- 50MHz
		rst					=> rst, -- Logic 0 triggering
		
		Tx_Start			=> Tx_Start,
		Tx_Data				=> Tx_Data, -- Only Data bits 
		UART_Tx_Pin			=> UART_Tx_Pin,	-- Data transmitting pin
		Tx_ready			=> Tx_ready	-- Status bit (UART Tx is trasnmitting/ ideal)

	);
	
	UART_TX_main: process
	begin
		rst 	 <= '0'; -- The only active-low signal
		Tx_Start <= '0';
		Tx_Data  <= x"00";
		wait for 100ns;
		rst 	 <= '1';
		wait for 100ns;
		
		wait until rising_edge(clk);
		Tx_Start <= '1';
		Tx_Data  <= "01010011"; -- Therefore, we see at output: (0) 1 1 0 0 1 0 1 0 (1) || Data Packet = 10 1010 0110 = 2A6
		wait until rising_edge(clk);
		Tx_Start <= '0';
		Tx_Data  <= x"00";
		
		
		
	
		wait;
	end process;




end rtl;