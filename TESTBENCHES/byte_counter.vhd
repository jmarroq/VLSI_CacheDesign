library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity byte_counter_tb is
end entity;

architecture behavioral of byte_counter_tb is
 
  component byte_counter
    port (
      clk, reset, enable: in std_logic;
      byte_cnt_out : out std_logic_vector(1 downto 0)
    );
  end component;

  --------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------
  signal clk_s, reset_s, enable_s : std_logic := '0';
  signal byte_cnt_s : std_logic_vector(1 downto 0);
  constant CLK_PERIOD : time := 10 ns;

begin
  --------------------------------------------------------------------
  -- UUT 
  --------------------------------------------------------------------
  uut: byte_counter
    port map (
      clk          => clk_s,
      reset        => reset_s,
      enable       => enable_s,
      byte_cnt_out => byte_cnt_s
    );

  --------------------------------------------------------------------
  -- Clock Generation
  --------------------------------------------------------------------
  clk_process : process
  begin
    loop
      clk_s <= '0';
      wait for CLK_PERIOD/2;
      clk_s <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;

  --------------------------------------------------------------------
  -- Stimulus 
  --------------------------------------------------------------------
  stim_proc : process
    procedure wait_cycles(N : in integer) is
    begin
      for i in 1 to N loop
        wait until falling_edge(clk_s);
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
    -- Generate one-cycle enable pulses every 2 clock cycles
    ----------------------------------------------------------------
    for i in 0 to 7 loop
      enable_s <= '1';  
      wait_cycles(1);
      enable_s <= '0'; 
      wait_cycles(1);
    end loop;

    report "=== BYTE COUNTER TEST COMPLETE ===" severity note;
    assert false severity failure;
  end process;
end architecture;
