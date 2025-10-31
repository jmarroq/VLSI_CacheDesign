library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_fsm_struct_tb is
end cache_fsm_struct_tb;

architecture behavioral of cache_fsm_struct_tb is

  --------------------------------------------------------------------
  -- UUT Declaration
  --------------------------------------------------------------------
  component cache_fsm_struct
    port (
      clk             : in  std_logic;
      reset           : in  std_logic;
      start           : in  std_logic;
      read_write      : in  std_logic;    
      cvt             : in  std_logic;    

      busy            : out std_logic;
      output_enable   : out std_logic;
      rw_enable       : out std_logic;
      mux_sel         : out std_logic;
      decoder_enable  : out std_logic;
      mem_enable      : out std_logic;
      valid_bit       : out std_logic;
      byte_cnt_out    : out std_logic_vector(1 downto 0)
    );
  end component;

  --------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------
  signal clk_s, reset_s, start_s, rw_s, cvt_s : std_logic := '0';
  signal busy_s, out_en_s, rw_en_s, mux_s, dec_s, mem_s, valid_s : std_logic;
  signal byte_cnt_s : std_logic_vector(1 downto 0);

  constant CLK_PERIOD : time := 10 ns;

begin
  --------------------------------------------------------------------
  -- UUT
  --------------------------------------------------------------------
  uut: cache_fsm_struct
    port map (
      clk             => clk_s,
      reset           => reset_s,
      start           => start_s,
      read_write      => rw_s,
      cvt             => cvt_s,
      busy            => busy_s,
      output_enable   => out_en_s,
      rw_enable       => rw_en_s,
      mux_sel         => mux_s,
      decoder_enable  => dec_s,
      mem_enable      => mem_s,
      valid_bit       => valid_s,
      byte_cnt_out    => byte_cnt_s
    );

  --------------------------------------------------------------------
  -- Clock Generation (10 ns period)
  --------------------------------------------------------------------
  clk_process : process
  begin
    while true loop
      clk_s <= '0';
      wait for CLK_PERIOD/2;
      clk_s <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;

  --------------------------------------------------------------------
  -- Stimulus Process
  --------------------------------------------------------------------
  stim : process
    procedure wait_cycles(N : in integer) is
    begin
      for i in 1 to N loop
        wait until rising_edge(clk_s);
      end loop;
    end procedure;
  begin
    ----------------------------------------------------------------
    -- RESET
    ----------------------------------------------------------------
    report "=== RESETTING FSM ===" severity note;
    reset_s <= '1';
    wait_cycles(2);
    reset_s <= '0';
    report "=== RELEASED RESET ===" severity note;

    wait_cycles(2);

    ----------------------------------------------------------------
    -- TEST 1: READ HIT  (start=1 pulse, rw=1, cvt=1)
    ----------------------------------------------------------------
    report "=== TEST 1: READ HIT ===" severity note;
    rw_s   <= '1';
    cvt_s  <= '1';
    start_s <= '1';
    wait_cycles(1);          -- one-cycle pulse
    start_s <= '0';
    rw_s    <= '0';          -- clear inputs after latch
    cvt_s   <= '0';
    wait_cycles(15);

    ----------------------------------------------------------------
    -- TEST 2: WRITE HIT  (start=1 pulse, rw=0, cvt=1)
    ----------------------------------------------------------------
    report "=== TEST 2: WRITE HIT ===" severity note;
    rw_s   <= '0';
    cvt_s  <= '1';
    start_s <= '1';
    wait_cycles(1);
    start_s <= '0';
    rw_s    <= '0';
    cvt_s   <= '0';
    wait_cycles(20);

    ----------------------------------------------------------------
    -- TEST 3: WRITE MISS (start=1 pulse, rw=0, cvt=0)
    ----------------------------------------------------------------
    report "=== TEST 3: WRITE MISS ===" severity note;
    rw_s   <= '0';
    cvt_s  <= '0';
    start_s <= '1';
    wait_cycles(1);
    start_s <= '0';
    rw_s    <= '0';
    cvt_s   <= '0';
    wait_cycles(25);

    ----------------------------------------------------------------
    -- TEST 4: READ MISS  (start=1 pulse, rw=1, cvt=0)
    ----------------------------------------------------------------
    report "=== TEST 4: READ MISS ===" severity note;
    rw_s   <= '1';
    cvt_s  <= '0';
    start_s <= '1';
    wait_cycles(1);
    start_s <= '0';
    rw_s    <= '0';
    cvt_s   <= '0';
    wait_cycles(30);

    ----------------------------------------------------------------
    -- END SIMULATION
    ----------------------------------------------------------------
    report "=== ALL TESTS COMPLETE ===" severity note;
    wait for 20 ns;
    assert false severity failure;
  end process;

end behavioral;
