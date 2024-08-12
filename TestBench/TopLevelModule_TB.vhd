library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevelModule_TB is
generic
(	
	RS232_DATA_BITS : integer := 8
);
end entity;

architecture rtl of TopLevelModule_TB is

	component TopLevelModule is
	generic
	(	
		RS232_DATA_BITS	: integer := 8;
		CLK_FREQ		: integer := 50000000; --50MHz
		BAUD_RATE		: integer := 115200
	);
	port 
	(
		clk 			: in std_logic;
		rst 			: in std_logic;
		
		RS232_Tx_Pin 	: out std_logic; -- transmits data bit by bit
		RS232_Rx_Pin 	: in std_logic -- receives data bit by bit
	);
	end component;
	
signal	clk 			:  std_logic := '0';
signal	rst 			:  std_logic;
		
signal	RS232_Tx_Pin 	:  std_logic; -- transmits data bit by bit
signal	RS232_Rx_Pin 	:  std_logic;
signal	transmittedData :  std_logic_vector(RS232_DATA_BITS-1 downto 0);	
signal	dataTX			:  std_logic_vector(RS232_DATA_BITS-1 downto 0);

 

begin
	
	clk <= not clk after 10ns;
	
	UUT: TopLevelModule
	generic map 
	(
		RS232_DATA_BITS => RS232_DATA_BITS,
		CLK_FREQ		=> 50000000, --50MHz
		BAUD_RATE		=> 115200
	)
	port map
	(
		clk 			=> clk,
		rst 			=> rst,
		
		RS232_Tx_Pin 	=> RS232_Tx_Pin,
		RS232_Rx_Pin 	=> RS232_Rx_Pin
	);
	
	
	TestProcess: process
		-- variable implicates this particular signal is only present within this process-block
		variable  dataVector 		: std_logic_vector(RS232_DATA_BITS-1 downto 0);	
		procedure DataToTransmit -- Name of the procedure
		(
			constant data : in integer -- Parameter where we pass the argument
		)is
		begin
			-- Type conversion : integer to std_logic_vector
			dataVector := std_logic_vector(to_unsigned(data, RS232_DATA_BITS));
			-- Function/procedure begins now
			
			-- PC transmits start bit
			RS232_Rx_Pin <= '0';
			wait for 8.7us;
			
			for i in 0 to RS232_DATA_BITS-1
			loop
				RS232_Rx_Pin <= dataVector(i);
				wait for 8.7us;
			end loop;
			
			-- PC transmits stop bit
			RS232_Rx_Pin <= '1';
			wait for 8.7us;
		end procedure;
		
		
	begin
		rst <= '0';
		RS232_Rx_Pin <= '1';
		wait for 100ns;
		rst <= '1';
		wait for 100ns;
		
		DataToTransmit(33);
		wait for 20us;
		DataToTransmit(44);
		wait for 20us;
		DataToTransmit(55);
		wait for 20us;
		-- Note: 
		-- Procedure is eqvt to a function
		-- A Procedure is called by its name and the argument value you need to pass.
	
		wait;
	end process;
	
	SerialToParallel_Process : process
	begin
		-- Detect start bit
		wait until falling_edge( RS232_Tx_Pin );
		-- reach the middle of start bit period
		wait for 4.3us;
		
		for i in 0 to RS232_DATA_BITS-1
		loop
			-- Sampling : 1 period from the middle of start bit period =  middle of every bit period
			wait for 8.7us;
			transmittedData(i) <=  RS232_Tx_Pin;
		end loop;
		--We wait for stop bit to pass
		wait for 8.7us;
		
		
		dataTX <= transmittedData;
	end process;

	



end rtl;