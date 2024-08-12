library ieee;
use ieee.std_logic_1164.all;

entity BaudClockGenerator_TB is
end entity;

architecture rtl of BaudClockGenerator_TB is
	
	
	-- We are telling TB file to look for "BaudClockGenerator " module with these ports.
	-- So we declare it as a component. 
	
	component BaudClockGenerator is --  S T E P 1
	generic
	(
			NUMBER_OF_CLK_PULSE : integer;		-- based on size of data packet
			CLK_FREQ			: integer;
			BAUD_RATE			: integer
	);
	port(
			clk			: in std_logic;
			rst			: in std_logic;		
			
			start		: in std_logic;
			ready		: out std_logic;
			baud_clock	: out std_logic

	);
	end component;
	
	-- Signal declaration of UUT signal on the RHS (port to Signal matching) --  S T E P 3
	signal clk			: std_logic:= '0';
	signal rst			: std_logic;
	signal start		: std_logic;
	signal ready		: std_logic;
	signal baud_clock	: std_logic;

begin

	-- Now we instantiate this component.
	-- We can make multiple instances.
	-- UUT is the instance name that we have chosen (Unit Under Test).
	
	
	
	clk <= not clk after 10ns; -- clk <= CLK_FREQ --  S T E P 4
	
	
	UUT: BaudClockGenerator  --  S T E P 2
	generic map
	(
			NUMBER_OF_CLK_PULSE 	=> 10,		-- based on size of data packet
			CLK_FREQ				=> 50000000,
			BAUD_RATE				=> 115200
	)
	port map 
	(	
			-- LHS = port name; RHS = signal name
			-- LHS port name of the instantance must match with the port name of the component
			-- RHS signal name can be anything but it wise to name the port and the singal under same name.
			-- Now, these signals on the RHS needs to be declared in the declaration part of the architecture.
			
			clk			=> clk,		-- Name of the port = clk; name of the signal that we wanna display this port as = clk.
			rst			=> rst,		-- input signal :in control of the user during rest.
			
			start		=> start,	-- input signal :in control of the user during rest.
			ready		=> ready,	-- output signal : no need to force value at the output. 
			baud_clock	=> baud_clock

	);
	
	
	
	-- main process with no sensitivity list	--  S T E P 5
	main: process
	begin
		rst <= '0';	-- asserted LOW signal.
		start <= '0';
		wait for 100ns;
		rst <= '1';
		wait until rising_edge(clk);
		start <= '1';
		wait until rising_edge(clk);
		start <= '0';
	
		wait;
	end process;



end rtl;