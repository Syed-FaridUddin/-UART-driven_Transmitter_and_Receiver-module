library ieee;
use ieee.std_logic_1164.all;

entity BaudClockGenerator is
generic
(
		NUMBER_OF_CLK_PULSE : integer;		-- based on size of data packet
		--CLK_FREQ			: integer;
		BAUD_RATE			: integer
);
port(
		clk			: in std_logic;
		rst			: in std_logic;		
		
		start		: in std_logic;
		ready		: out std_logic;
		baud_clock	: out std_logic

);
end entity;

architecture rtl of BaudClockGenerator is

-- ************************************************ --
-- port		: small_alphabet_with_underscore
-- signals		: smallAlphabetWithThisFont
-- GENERICS		: ALL_CAPS_WITH_UNDERSCORE
-- ************************************************ --

constant bitPeriod		: integer:= 1/BAUD_RATE;
signal bitPeriodCounter : integer range 0 to bitPeriod;

signal clockCounter		: integer range 0 to NUMBER_OF_CLK_PULSE;


begin

	BaudClkGen : process (rst, clk)
	begin	
		if rst = '0' then
			bitPeriodCounter <= 0;
			baud_clock <= '0';		
		elsif rising_edge(clk) then
			if ready = '0' then		--  baud_clock is generated when we're busy or ready = '0'.
				if bitPeriodCounter < bitPeriod then
					bitPeriodCounter <= bitPeriodCounter + 1;
				else
					baud_clock <= '1';	-- generate baud_clock at every bitperiod.
					bitPeriodCounter <= 0;	
				end if;	
			end if;
		end if;		
	end process;
	
	
	ClockCounterProcess:process (rst, clk)
	begin	
		if rst = '0' then
			clockCounter <= 0;		
		elsif rising_edge(clk) then		
			if baud_clock  = '1' then
				clockCounter <= clockCounter - 1;	-- Each baud pulse decreases nos of the remainig clock pulse to be txd.	
			end if;			
		end if;	
	end process; 	
	
	
	StartAndReadyProcess:  process (rst, clk)
	begin	
		if rst = '0' then
			ready <= '1';
		elsif rising_edge(clk) then
			if start = '1' then	
				clockCounter <= NUMBER_OF_CLK_PULSE; -- we haven't synchronized start bc we are only going to simulate atm.
				ready <= '0';	-- We are ready to transmit new packet when clock counter is 0
			else 
				if clockCounter = 0 then
					ready <= '1';	-- We are ready to transmit new packet when clock counter is 0
				else 
					ready <= '0';
				end if;
			end if;
		end if;	
	end process;


end rtl;