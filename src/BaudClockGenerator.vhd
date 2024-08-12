library ieee;
use ieee.std_logic_1164.all;

entity BaudClockGenerator is
generic
(
		NUMBER_OF_CLK_PULSE : integer;		-- based on size of data packet that is required to be txd (not same as clock)
		CLK_FREQ			: integer;		-- CLK_FREQ = clk but we define it seperately to do the calculation for bit-period and baud-rate
		BAUD_RATE			: integer;
		IS_UART_RX			: boolean 
);
port(
		clk			: in std_logic;  -- should be same as CLK_FREQ. 
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

constant bitPeriod		: integer:= CLK_FREQ/BAUD_RATE; -- bitPeriod is nos of clock cycles needed to transmit one bit. 
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
					baud_clock <= '0';
					bitPeriodCounter <= bitPeriodCounter + 1;					
				else
					baud_clock <= '1';	-- generate baud_clock at every bitperiod.
					bitPeriodCounter <= 0;	
				end if;	
			else --new	
				baud_clock <= '0';
				if IS_UART_RX = true then
					bitPeriodCounter <= bitPeriod/2; -- to sample value at the mid of 8.7us
				else 
					bitPeriodCounter <= 0;
				end if;
			end if;
		end if;		
	end process;
	
	
	StartAndReadyProcess:  process (rst, clk)
	begin	
		if rst = '0' then
			ready <= '1';
			clockCounter <= 0; -- new
		elsif rising_edge(clk) then
			if start = '1' then	
				clockCounter <= NUMBER_OF_CLK_PULSE; -- we haven't synchronized start bc we are only going to simulate atm.
				ready <= '0';	-- Busy transmitting package.
			else -- start-signal is on only for one clk cycle and then it goes low. But we transmit data for ~10 clk cycles.
				if clockCounter = 0 then
					ready <= '1';	-- We are "again" ready to transmit new packet when clock counter is 0
				else -- clockCounter was loaded by start-signal and now we are transmitting.
					ready <= '0';
					if baud_clock  = '1' then
						clockCounter <= clockCounter - 1;	-- Each baud pulse decreases nos of the remainig clock pulse to be txd.	
					end if;
				end if;
			end if;
		end if;	
	end process;
	
	
	
	
	
	--ClockCounterProcess:process (rst, clk)
	--begin	
		--if rst = '0' then
			--clockCounter <= 0;		
		--elsif rising_edge(clk) then		
			--if baud_clock  = '1' then
			--	clockCounter <= clockCounter - 1;	-- Each baud pulse decreases nos of the remainig clock pulse to be txd.	
			--end if;			
		--end if;	
	--end process; 	
	
	
	
	
	
	
	-- N O T E :
	-- We cannot let two process change the value of a signal.
	-- We can only let multpile processes to use a signal to compare values.
	


end rtl;