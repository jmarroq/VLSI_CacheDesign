library IEEE;
use IEEE.std_logic_1164.all;

-- Testbench for the cvt entity (Cache Tag Validator)
entity tb_cvt is
end tb_cvt;

architecture tb of tb_cvt is

	-- Component declaration for the Unit Under Test (UUT)
	component cvt
    	port (
        	input1 : in std_logic_vector(1 downto 0); -- input Tag[1:0]
        	input2 : in std_logic_vector(1 downto 0); -- cache Tag[1:0]
        	valid  : in std_logic;               	-- valid bit
        	output : out std_logic               	-- hit / miss
    	);
	end component;

	-- Signal declarations - must match the component's ports
	signal s_input1 : std_logic_vector(1 downto 0) := (others => '0');
	signal s_input2 : std_logic_vector(1 downto 0) := (others => '0');
	signal s_valid  : std_logic := '0';
	signal s_output : std_logic;

	-- Simulation constants
	constant C_CLOCK_PERIOD : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: cvt
    	port map (
        	input1 => s_input1,
        	input2 => s_input2,
        	valid  => s_valid,
        	output => s_output
    	);

	-- Clock generation process (not strictly needed for synchronous logic, but useful for timing)
	clk_process : process
	begin
    	-- Assuming a combinational logic, a clock is not strictly necessary,
    	-- but a small delay helps to observe changes.
    	wait for C_CLOCK_PERIOD / 2;
    	wait for C_CLOCK_PERIOD / 2;
    	-- Clock not strictly used for sequential logic here, so just relying on wait times.
    	wait;
	end process clk_process;


	-- Stimulus generation process
	stim_process : process
	begin

    	-- =================================================================
    	-- Test Case 1: Match (I1=00, I2=00, V=1) -> HIT (1)
    	-- =================================================================
 	 
    	s_input1 <= "00";
    	s_input2 <= "00";
    	s_valid  <= '1';
    	wait for C_CLOCK_PERIOD;



    	-- =================================================================
    	-- Test Case 2: Mismatch (I1=01, I2=00, V=1) -> MISS (0)
    	-- =================================================================
  	 
    	s_input1 <= "01";
    	s_input2 <= "00";
    	s_valid  <= '1';
    	wait for C_CLOCK_PERIOD;

 

    	-- =================================================================
    	-- Test Case 3: Match but Invalid (I1=11, I2=11, V=0) -> MISS (0)
    	-- The AND gate structure means if valid is '0', the output is '0'.
    	-- =================================================================
  	 
    	s_input1 <= "11";
    	s_input2 <= "11";
    	s_valid  <= '1';
    	wait for C_CLOCK_PERIOD;


    	-- =================================================================
    	-- Test Case 4: Mismatch and Invalid (I1=10, I2=01, V=0) -> MISS (0)
    	-- =================================================================
   	 
    	s_input1 <= "10";
    	s_input2 <= "01";
    	s_valid  <= '0';
    	wait for C_CLOCK_PERIOD;

  	 
    	-- =================================================================
    	-- Test Case 5: Match (I1=10, I2=10, V=1) -> HIT (1)
    	-- =================================================================
   	 
    	s_input1 <= "10";
    	s_input2 <= "10";
    	s_valid  <= '1';
    	wait for C_CLOCK_PERIOD;

 	 
    	wait;
	end process stim_process;

end tb;

