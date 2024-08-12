library ieee;
use ieee.std_logic_1164.all;

entity Synchronizer_TB is
end entity;


architecture rtl of Synchronizer_TB is

	component Synchronizer is
	port
	(
		clk		: in std_logic;
		rst		: in std_logic;
		
		Async	: in std_logic;
		Sync	: out std_logic

	);
	end component;
	----------------------------------------------------
	signal	clk		:  std_logic:= '0';
	signal	rst		:  std_logic;
		
	signal	Async	:  std_logic;
	signal	Sync	:  std_logic;

begin



	clk <= not clk after 10ns;
	
	
	
	UUT: Synchronizer 
	port map
	(
		clk		=> clk,
		rst		=> rst,
		
		Async	=> Async,
		Sync	=> Sync

	);
	
	main: process
	begin
		rst <= '0';
		Async <= '1'; --ideal value is '1'.
		wait for 100ns;
		rst <= '1';
		wait for 100ns;		
		wait for 3ns;
		Async <= '0';	
	
		wait;
	end process;



end rtl;