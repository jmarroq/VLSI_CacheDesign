library IEEE;
use IEEE.std_logic_1164.all;
-- Import libraries for formatted output to the console (standard output)
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity tb_mux2to1_2bit is
    -- The testbench entity is typically empty
end tb_mux2to1_2bit;

architecture behavior of tb_mux2to1_2bit is

    -- Declare the component (Unit Under Test - UUT)
    component mux2to1_2bit
    port (
        S   : in  std_logic;
        I0  : in  std_logic_vector(1 downto 0);
        I1  : in  std_logic_vector(1 downto 0);
        Y   : out std_logic_vector(1 downto 0)
    );
    end component;

    -- Signal Declarations for connecting to the UUT ports
    signal tb_S  : std_logic := '0';
    signal tb_I0 : std_logic_vector(1 downto 0) := "00";
    signal tb_I1 : std_logic_vector(1 downto 0) := "00";

    -- Output signal
    signal tb_Y : std_logic_vector(1 downto 0);

    -- Constant for simulation time
    constant c_DELAY : time := 10 ns;

    -- Procedure to print current state to the console
    procedure REPORT_STATUS is
        variable v_LINE : line;
    begin
        -- Write timestamp
        write(v_LINE, string'("Time: "));
        write(v_LINE, now, right, 10);

        -- Write inputs
        write(v_LINE, string'(" | S: "));
        write(v_LINE, tb_S);
        write(v_LINE, string'(" | I0: "));
        write(v_LINE, tb_I0);
        write(v_LINE, string'(" | I1: "));
        write(v_LINE, tb_I1);

        -- Write output
        write(v_LINE, string'(" | Y (OUT): "));
        write(v_LINE, tb_Y);

        -- Print the line to the standard output
        writeline(output, v_LINE);
    end procedure;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: mux2to1_2bit
    port map ( S  => tb_S,
               I0 => tb_I0,
               I1 => tb_I1,
               Y  => tb_Y
             );

    -- Stimulus process: Generates test vectors
    stim_proc: process
    begin
       
        -- Wait briefly for initial signals to stabilize
        wait for 1 ns;

        -- --------------------------------------------------------
        -- Phase 1: Test S = '0' (Selects Input I0)
        -- --------------------------------------------------------
        tb_S <= '0';
        wait for c_DELAY; -- Wait for S change to propagate
     
        -- Test 1: I0="00", I1="11". Expected Y="00"
        tb_I0 <= "00"; tb_I1 <= "11";
        wait for c_DELAY; 

        -- Test 2: I0="01", I1="00". Expected Y="01"
        tb_I0 <= "01"; tb_I1 <= "00";
        wait for c_DELAY; 
        
        -- Test 3: I0="10", I1="11". Expected Y="10"
        tb_I0 <= "10"; tb_I1 <= "11";
        wait for c_DELAY; 

        -- Test 4: I0="11", I1="00". Expected Y="11"
        tb_I0 <= "11"; tb_I1 <= "00";
        wait for c_DELAY; 


        -- --------------------------------------------------------
        -- Phase 2: Test S = '1' (Selects Input I1)
        -- --------------------------------------------------------
        tb_S <= '1';
        wait for c_DELAY; -- Wait for S change to propagate
    

        -- Test 5: I0="00", I1="11". Expected Y="11"
        tb_I0 <= "00"; tb_I1 <= "11";
        wait for c_DELAY; 

        -- Test 6: I0="01", I1="00". Expected Y="00"
        tb_I0 <= "01"; tb_I1 <= "00";
        wait for c_DELAY; 

        -- Test 7: I0="10", I1="01". Expected Y="01"
        tb_I0 <= "10"; tb_I1 <= "01";
        wait for c_DELAY; 

        -- Test 8: I0="11", I1="10". Expected Y="10"
        tb_I0 <= "11"; tb_I1 <= "10";
        wait for c_DELAY;

        -- Final wait to end simulation
     
        wait;

    end process;

end behavior;
