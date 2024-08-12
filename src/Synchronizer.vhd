library ieee;
use ieee.std_logic_1164.all;

entity Synchronizer is

port
(
	clk		: in std_logic;
	rst		: in std_logic;
	
	Async	: in std_logic;
	Sync	: out std_logic

);
end entity;


architecture rtl of Synchronizer is

	signal sync_ff : std_logic_vector(1 downto 0);

begin
	
	Sync <= sync_ff(1);
	
	Synchronization_process : process (clk, rst)
	begin
		if rst = '0' then
			sync_ff <= "11";
		elsif rising_edge(clk) then
			sync_ff(0) <= Async;
			sync_ff(1) <= sync_ff(0);
			-- Left shift [ we copy 0th bit location content to 1st bit location]
		end if;	
	end process;



end rtl;