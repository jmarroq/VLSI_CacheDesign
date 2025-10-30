library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cycle_counter_tb is
end cycle_counter_tb;

architecture behavioral of cycle_counter_tb is
  
  component cycle_counter
    port (
      clk, reset, enable: in std_logic;
      c0, c11, c13, c15, c17, c18 : out std_logic
    );
  end component;

  --------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------
  signal clk_s, reset_s, enable_s : std_logic := '0';
  signal c0_s, c11_s, c13_s, c15_s, c17_s, c18_s : std_logic;

  constant CLK_PERIOD : time := 10 ns;

begin
  --------------------------------------------------------------------
  -- UUT
  --------------------------------------------------------------------
  uut: cycle_counter
    port map (
      clk    => clk_s,
      reset  => reset_s,
      enable => enable_s,
      c0     => c0_s,
      c11    => c11_s,
      c13    => c13_s,
      c15    => c15_s,
      c17    => c17_s,
      c18    => c18_s
    );

  --------------------------------------------------------------------
  -- Clock Generation
  --------------------------------------------------------------------
  clk_process: process
  begin
    loop
      clk_s <= '0';
      wait for CLK_PERIOD / 2;
      clk_s <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  --------------------------------------------------------------------
  -- Stimulus
  --------------------------------------------------------------------
  stim_process: process
    -- Helper: wait for N clock cycles
    procedure wait_cycles(N : in integer) is
    begin
      for i in 1 to N loop
        wait until rising_edge(clk_s);
      end loop;
    end procedure;
  begin
    ----------------------------------------------------------------
    -- RESET phase
    ----------------------------------------------------------------
    report "=== RESETTING COUNTER ===" severity note;
    reset_s  <= '1';
    enable_s <= '0';
    wait_cycles(3);         

    reset_s  <= '0';  
     wait_cycles(1);   
    enable_s <= '1';        
    report "=== RUNNING COUNTER ===" severity note;

    ----------------------------------------------------------------
    -- RUN counter for ~25 cycles
    ----------------------------------------------------------------
     wait_cycles(25);          

    ----------------------------------------------------------------
    -- PAUSE
    ----------------------------------------------------------------
    enable_s <= '0';
    wait_cycles(3);
    report "=== COUNTER TEST COMPLETE ===" severity note;
    assert false severity failure;
  end process;

end behavioral;
