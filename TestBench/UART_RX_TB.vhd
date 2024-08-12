library ieee;
use ieee.std_logic_1164.all;

entity UART_RX_TB is
generic
(
	DATA_WIDTH : integer := 8
);

end entity;

architecture rtl of UART_RX_TB is 

	component UART_RX is
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
		RS232_IRQ		: out std_logic; 
		RS232_IRQ_CLEAR : in std_logic


	);
	end component;
 ---------------------------------------------
 
signal 		clk		 		:  std_logic := '0';
signal		rst		 		:  std_logic;
		
signal		RS232_RX 		:  std_logic;
signal		RS232_DATA 		:  std_logic_vector(DATA_WIDTH-1 downto 0);
signal		RS232_IRQ		:  std_logic; 
signal		RS232_IRQ_CLEAR :  std_logic;	
	
	
begin

	UUT : UART_RX 
	generic map
	(
		DATA_WIDTH => DATA_WIDTH
	)
	port map
	(
		clk		 		=> clk,
		rst		 		=> rst,
		
		RS232_RX 		=> RS232_RX,
		RS232_DATA 		=> RS232_DATA,
		RS232_IRQ		=> RS232_IRQ, 
		RS232_IRQ_CLEAR => RS232_IRQ_CLEAR
	);
	
	clk <= not clk after 10ns;
	
	TestProcess: process
	begin
		rst <= '0';
		RS232_RX <= '1'; -- ideal state is transmitted
		RS232_IRQ_CLEAR <= '0'; -- we do not have a IRQ signal to clear in the beginning.
		wait for 100ns;
		rst <= '1';
		wait for 100ns;
		
		-- We transmit x"AA" => '0' + LSB_First(x"AA")
		-- Therefore we transmit: 0   0 1 0 1  0 1 0 1 (left to right)
		-- transmission is asynchronus
		-- two bits are seperated by bit period : 8.7us
		-- 0 10101010 1 ~  0101 0101 = x"55"
		-- start bit
		RS232_RX <= '0';
		wait for 8.7us;
		
		-- Data LSB first
		for i in 0 to 3 loop
			RS232_RX <= '1';
			wait for 8.7us;
			RS232_RX <= '0';
			wait for 8.7us;
		end loop;
		
		-- stop bit
		RS232_RX <= '1';
		wait for 8.7us;
		
		-- RS232_IRQ is asserted here, so we need to deassert it, to start nect data-packet reception.
		wait for 50ns;
		RS232_IRQ_CLEAR <= '1';
		wait until rising_edge(clk);
		RS232_IRQ_CLEAR <= '0';
	
		wait;
	end process;

	


end rtl;