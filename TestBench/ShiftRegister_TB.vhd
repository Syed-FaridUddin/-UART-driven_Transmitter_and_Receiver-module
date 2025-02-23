library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister_TB is
generic
(
	CHAIN_LENGTH 	: integer := 8

);
end entity;


architecture rtl of ShiftRegister_TB is

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
--------------------------------------------------------------------------------

	signal 	clk				:  std_logic := '0';
	signal	rst				:  std_logic;
			
	signal	Shift_Enable	:  std_logic;
	signal	Din				:  std_logic;
	signal	Dout			:  std_logic_vector(CHAIN_LENGTH-1 downto 0);
-----------------------------------------------------------------------------------

begin
	
	UUT: ShiftRegister 
	generic map
	(
		CHAIN_LENGTH 	=> CHAIN_LENGTH

	)
	port map
	(
		clk				=> clk,
		rst				=> rst,
		
		Shift_Enable	=> Shift_Enable,
		Din				=> Din,
		Dout			=> Dout
	);
--------------------------------------------------------------------

	
	clk <= not clk after 10ns ;
	
	
	
	main : process
	begin
		rst <= '0';
		Din <= '0';
		Shift_Enable <= '0';
		wait for 100ns;
		rst <= '1';
		wait for 100ns;
		
		-- UART_Tx transmits x"6B" = "01101011" LSB first 
		-- Din is:  1 1 0 1 0 1 1 0
		
		for i in 0 to 1 loop
			Din <= '1';	-- asynchronus input
			wait for 4.35us; -- We are sampling bits in the middle of bit period = 8.7us/2
			wait until rising_edge(clk);
			Shift_Enable <= '1';
			wait until rising_edge(clk);
			Shift_Enable <= '0';
			wait for 4.35us; -- we wait till the end of bit period...
		end loop;
		
		for i in 0 to 1 loop
			Din <= '0';	-- (contd.) and then we transfer next bit
			wait for 4.35us; -- We are sampling bits in the middle of bit period = 8.7us/2
			wait until rising_edge(clk);
			Shift_Enable <= '1';
			wait until rising_edge(clk);
			Shift_Enable <= '0';
			wait for 4.35us;
			
			Din <= '1';	-- asynchronus input
			wait for 4.35us; -- We are sampling bits in the middle of bit period = 8.7us/2
			wait until rising_edge(clk);
			Shift_Enable <= '1';
			wait until rising_edge(clk);
			Shift_Enable <= '0';
			wait for 4.35us;
		end loop;
		
		Din <= '1';	-- asynchronus input
		wait for 4.35us; -- We are sampling bits in the middle of bit period = 8.7us/2
		wait until rising_edge(clk);
		Shift_Enable <= '1';
		wait until rising_edge(clk);
		Shift_Enable <= '0';
		wait for 4.35us;
		
		Din <= '0';	-- asynchronus input
		wait for 4.35us; -- We are sampling bits in the middle of bit period = 8.7us/2
		wait until rising_edge(clk);
		Shift_Enable <= '1';
		wait until rising_edge(clk);
		Shift_Enable <= '0';
		wait for 4.35us;

		wait;
	end process;
	

end rtl;