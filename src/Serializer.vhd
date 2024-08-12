library ieee;
use ieee.std_logic_1164.all;

entity Serializer is
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
end entity;


architecture rtl of Serializer is

	signal shiftReg		: std_logic_vector(DATA_WIDTH-1 downto 0);

begin
	Dout <= shiftReg(0);
	
	SerializerProcess: process(clk,rst)
	begin
		if rst = '0' then
			shiftReg <= (others => DEFAULT_VALUE);
		elsif rising_edge(clk) then
			if Load = '1' then
				shiftReg <= Din;
			elsif Shift_Enable = '1' then
				shiftReg <= '1' & shiftReg(DATA_WIDTH-1 downto 1); -- right shift operation and inserting '1' from the left.			
			end if;		
		end if;	
	end process;


end rtl;