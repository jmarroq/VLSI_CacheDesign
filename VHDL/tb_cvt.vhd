library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

-- Testbench for the cvt entity (Cache Tag Validator)
entity cvt_tb is
end cvt_tb;

architecture behavior of cvt_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component cvt
        port (
            input1 : in std_logic_vector(1 downto 0); -- input Tag[1:0]
            input2 : in std_logic_vector(1 downto 0); -- cache Tag[1:0]
            valid  : in std_logic;                   -- valid bit
            output : out std_logic                   -- hit / miss
        );
    end component;

    -- Signal declarations - must match the component's ports
    signal s_input1 : std_logic_vector(1 downto 0) := (others => '0');
    signal s_input2 : std_logic_vector(1 downto 0) := (others => '0');
    signal s_valid  : std_logic := '0';
    signal s_output : std_logic;

    -- Simulation constants
    constant C_CLOCK_PERIOD : time := 10 ns;

    -- File for test results (optional, but good practice)
    file results_file : text open WRITE_MODE is "cvt_test_results.txt";

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
        variable v_line : line;
    begin

        -- Write header to file
        write(v_line, string'("--- CVT Test Results ---"));
        writeline(results_file, v_line);
        write(v_line, string'("Time | I1 | I2 | V | Expected | Actual | Result"));
        writeline(results_file, v_line);

        -- =================================================================
        -- Test Case 1: Match (I1=00, I2=00, V=1) -> HIT (1)
        -- =================================================================
        report "Applying Test Case 1: Match with Valid (00 vs 00)";
        s_input1 <= "00";
        s_input2 <= "00";
        s_valid  <= '1';
        wait for C_CLOCK_PERIOD;

        -- Check result
        assert s_output = '1'
            report "Test 1 Failed: Expected HIT ('1'), got MISS ('0')" severity error;

        write(v_line, now, left);
        write(v_line, string'(" | ")); write(v_line, s_input1);
        write(v_line, string'(" | ")); write(v_line, s_input2);
        write(v_line, string'(" | ")); write(v_line, s_valid);
        write(v_line, string'(" | 1      | ")); write(v_line, s_output);
        write(v_line, string'(" | PASS"));
        writeline(results_file, v_line);


        -- =================================================================
        -- Test Case 2: Mismatch (I1=01, I2=00, V=1) -> MISS (0)
        -- =================================================================
        report "Applying Test Case 2: Mismatch with Valid (01 vs 00)";
        s_input1 <= "01";
        s_input2 <= "00";
        s_valid  <= '1';
        wait for C_CLOCK_PERIOD;

        -- Check result
        assert s_output = '0'
            report "Test 2 Failed: Expected MISS ('0'), got HIT ('1')" severity error;

        write(v_line, now, left);
        write(v_line, string'(" | ")); write(v_line, s_input1);
        write(v_line, string'(" | ")); write(v_line, s_input2);
        write(v_line, string'(" | ")); write(v_line, s_valid);
        write(v_line, string'(" | 0      | ")); write(v_line, s_output);
        write(v_line, string'(" | PASS"));
        writeline(results_file, v_line);

        -- =================================================================
        -- Test Case 3: Match but Invalid (I1=11, I2=11, V=0) -> MISS (0)
        -- The AND gate structure means if valid is '0', the output is '0'.
        -- =================================================================
        report "Applying Test Case 3: Match but Invalid (11 vs 11)";
        s_input1 <= "11";
        s_input2 <= "11";
        s_valid  <= '0';
        wait for C_CLOCK_PERIOD;

        -- Check result
        assert s_output = '0'
            report "Test 3 Failed: Expected MISS ('0'), got HIT ('1')" severity error;

        write(v_line, now, left);
        write(v_line, string'(" | ")); write(v_line, s_input1);
        write(v_line, string'(" | ")); write(v_line, s_input2);
        write(v_line, string'(" | ")); write(v_line, s_valid);
        write(v_line, string'(" | 0      | ")); write(v_line, s_output);
        write(v_line, string'(" | PASS"));
        writeline(results_file, v_line);

        -- =================================================================
        -- Test Case 4: Mismatch and Invalid (I1=10, I2=01, V=0) -> MISS (0)
        -- =================================================================
        report "Applying Test Case 4: Mismatch and Invalid (10 vs 01)";
        s_input1 <= "10";
        s_input2 <= "01";
        s_valid  <= '0';
        wait for C_CLOCK_PERIOD;

        -- Check result
        assert s_output = '0'
            report "Test 4 Failed: Expected MISS ('0'), got HIT ('1')" severity error;

        write(v_line, now, left);
        write(v_line, string'(" | ")); write(v_line, s_input1);
        write(v_line, string'(" | ")); write(v_line, s_input2);
        write(v_line, string'(" | ")); write(v_line, s_valid);
        write(v_line, string'(" | 0      | ")); write(v_line, s_output);
        write(v_line, string'(" | PASS"));
        writeline(results_file, v_line);

        -- =================================================================
        -- Test Case 5: Match (I1=10, I2=10, V=1) -> HIT (1)
        -- =================================================================
        report "Applying Test Case 5: Match with Valid (10 vs 10)";
        s_input1 <= "10";
        s_input2 <= "10";
        s_valid  <= '1';
        wait for C_CLOCK_PERIOD;

        -- Check result
        assert s_output = '1'
            report "Test 5 Failed: Expected HIT ('1'), got MISS ('0')" severity error;

        write(v_line, now, left);
        write(v_line, string'(" | ")); write(v_line, s_input1);
        write(v_line, string'(" | ")); write(v_line, s_input2);
        write(v_line, string'(" | ")); write(v_line, s_valid);
        write(v_line, string'(" | 1      | ")); write(v_line, s_output);
        write(v_line, string'(" | PASS"));
        writeline(results_file, v_line);

        -- End of simulation
        report "Simulation completed successfully. Check cvt_test_results.txt for output." severity note;
        wait;
    end process stim_process;

end behavior;
