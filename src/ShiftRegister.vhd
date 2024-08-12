-- Serial to parallel data conversion
library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister is
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
end entity;


architecture rtl of ShiftRegister is

	signal shiftRegOut : std_logic_vector(CHAIN_LENGTH-1 downto 0);

begin
	
	-- We cannot drive output signal directly, or use it in calculations. So we use a signal "shiftRegOut" and finally we assign it to 'Dout' via a wire.
	
	Dout <= shiftRegOut; 
	
	ShiftRegister_Process: process (clk, rst)
	begin	
		if rst = '0' then -- Then only active LOW signal
			shiftRegOut <= (others => '0'); -- right shift operation as UART transfers LSB first.
		elsif rising_edge(clk) Then
			if Shift_Enable = '1' then
				shiftRegOut <= Din & shiftRegOut(shiftRegOut'left downto 1);
			end if;
		end if;	
	end process;

end rtl;