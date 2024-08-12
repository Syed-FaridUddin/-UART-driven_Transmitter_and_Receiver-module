library ieee;
use ieee.std_logic_1164.all;

entity	Serializer_TB is
	-- It is a good practice to have parameters that can be changed at the top for easier access.
	generic
	(

		DATA_WIDTH		: integer := 8;
		DEFAULT_VALUE 	: std_logic := '1'

	);
end entity;

architecture rtl of Serializer_TB is

	component Serializer is		-- S T E P 1 => component declaration
	generic
	(

		DATA_WIDTH		: integer;
		DEFAULT_VALUE 	: std_logic

	);
	port
	(

		clk				: in std_logic := '0';
		rst				: in std_logic;

		Shift_Enable	: in std_logic;
		Load			: in std_logic;
		Din				: in std_logic_vector(DATA_WIDTH-1 downto 0);
		Dout			: out std_logic

	);
	end component;

	-- S T E P 3 => Signal declaration
	--constant DATA_WIDTH 	: integer := 8;
	
 	signal	clk				:  std_logic := '0';
	signal	rst				:  std_logic;

	signal	Shift_Enable	:  std_logic;
	signal	Load			:  std_logic;
	signal	Din				:  std_logic_vector(DATA_WIDTH-1 downto 0); -- This DATA_WIDTH needs to be defined so that we can use it. SO we use a constant to define it.
	signal	Dout			:  std_logic;
	

begin



	clk <= not clk after 10ns;	---- S T E P 4 => clk generation f = 50MHz 
	
	UUT: Serializer 	-- S T E P 2 => calling instance
	generic map
	(

		DATA_WIDTH		=> DATA_WIDTH, -- we map the generic DATA_WIDTH to the above declared DATA_WIDTH constant or by defining gegeric in the entity of TB.
		DEFAULT_VALUE 	=> DEFAULT_VALUE -- Mapped to the above declared generic value.

	)
	port map
	(

		clk				=> clk,
		rst				=> rst,

		Shift_Enable	=> Shift_Enable,
		Load			=> Load,
		Din				=> Din,
		Dout			=> Dout

	);
	
	
	
	main: process
	begin
		rst <= '0'; -- rst enabled
		Shift_Enable <= '0'; -- All input signals disabled
		Load <= '0';
		Din <= x"00";
		wait for 100ns;
		rst <= '1'; --rst disabled
		wait for 100ns;
		
		wait until rising_edge(clk);
		Load <= '1';
		Din <= x"AA";
		wait until rising_edge(clk); -- we don't need Load or Din after a clock cycle. Shift register has stored it, we can load Din with new values in the mean time.
		Load <= '0';
		Din <= x"00";
		
		for i in 0 to (DATA_WIDTH-1) loop		
			wait for 8.7us; -- to incorporate bit dealy (baud rate)
			wait until rising_edge(clk);
			Shift_Enable <= '1';
			wait until rising_edge(clk);
			Shift_Enable <= '0';
		end loop;	
		
	
	
		wait;
	end process;



end rtl;