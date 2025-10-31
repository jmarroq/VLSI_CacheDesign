library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity output_logic_tb is
end output_logic_tb;

architecture behavioral of output_logic_tb is

  --------------------------------------------------------------------
  -- UUT DECLARATION
  --------------------------------------------------------------------
  component output_logic
    port(
      state_in        : in  std_logic_vector(2 downto 0);
      rw_lat, cvt_lat : in  std_logic;
      c8_neg, c9_neg, c11_neg, c13_neg, c15_neg : in std_logic;
      c9_pos, c11_pos, c13_pos, c15_pos : in std_logic;
      busy, output_enable, rw_enable, mux_sel,
      decoder_enable, mem_enable, valid_bit, byte_enable : out std_logic
    );
  end component;

  --------------------------------------------------------------------
  -- SIGNALS
  --------------------------------------------------------------------
  signal state_in_s : std_logic_vector(2 downto 0) := (others => '0');
  signal rw_lat_s, cvt_lat_s : std_logic := '0';
  signal c8n_s, c9n_s, c11n_s, c13n_s, c15n_s : std_logic := '0';
  signal c9p_s, c11p_s, c13p_s, c15p_s : std_logic := '0';

  signal busy_s, output_enable_s, rw_enable_s, mux_sel_s : std_logic;
  signal decoder_enable_s, mem_enable_s, valid_bit_s, byte_enable_s : std_logic;

  signal clk_s : std_logic := '0';
  constant CLK_PERIOD : time := 10 ns;
  constant T : time := 10 ns;

begin
  --------------------------------------------------------------------
  -- UUT
  --------------------------------------------------------------------
  uut: output_logic
    port map(
      state_in        => state_in_s,
      rw_lat          => rw_lat_s,
      cvt_lat         => cvt_lat_s,
      c8_neg          => c8n_s,
      c9_neg          => c9n_s,
      c11_neg         => c11n_s,
      c13_neg         => c13n_s,
      c15_neg         => c15n_s,
      c9_pos          => c9p_s,
      c11_pos         => c11p_s,
      c13_pos         => c13p_s,
      c15_pos         => c15p_s,
      busy            => busy_s,
      output_enable   => output_enable_s,
      rw_enable       => rw_enable_s,
      mux_sel         => mux_sel_s,
      decoder_enable  => decoder_enable_s,
      mem_enable      => mem_enable_s,
      valid_bit       => valid_bit_s,
      byte_enable     => byte_enable_s
    );

  --------------------------------------------------------------------
  -- CLOCK
  --------------------------------------------------------------------
  clk_proc: process
  begin
    loop
      clk_s <= '0'; wait for CLK_PERIOD/2;
      clk_s <= '1'; wait for CLK_PERIOD/2;
    end loop;
  end process;

  --------------------------------------------------------------------
  -- TEST SEQUENCE (READ MISS)
  --------------------------------------------------------------------
  stim_proc: process
    procedure wait_cycles(N: integer) is
    begin
      for i in 1 to N loop
        wait until rising_edge(clk_s);
      end loop;
    end procedure;
  begin
    report "=== BEGIN OUTPUT_LOGIC TEST ===" severity note;

    ----------------------------------------------------------------
    -- 1. IDLE STATE (000)
    ----------------------------------------------------------------
    state_in_s <= "000";
    rw_lat_s   <= '1';  -- read
    cvt_lat_s  <= '1';  -- valid
    wait_cycles(2);

    ----------------------------------------------------------------
    -- 2. LATCH (001)
    ----------------------------------------------------------------
    state_in_s <= "001";
    wait_cycles(2);

    ----------------------------------------------------------------
    -- 3. DECIDE (010) - READ MISS
    ----------------------------------------------------------------
    state_in_s <= "010";
    wait for T;

    ----------------------------------------------------------------
    -- Case 1: READ HIT (rw=1, cvt=1)
    -- Expect: decoder_enable=1, output_enable=1, mux_sel=0, mem_enable=0
    ----------------------------------------------------------------
    rw_lat_s <= '1'; cvt_lat_s <= '1';
    wait for T;

    ----------------------------------------------------------------
    -- Case 2: WRITE HIT (rw=0, cvt=1)
    -- Expect: decoder_enable=1, output_enable=0, mux_sel=1, mem_enable=0
    ----------------------------------------------------------------
    rw_lat_s <= '0'; cvt_lat_s <= '1';
    wait for T;

    ----------------------------------------------------------------
    -- Case 3: READ MISS (rw=1, cvt=0)
    -- Expect: decoder_enable=0, output_enable=0, mux_sel=0, mem_enable=1
    ----------------------------------------------------------------
    rw_lat_s <= '1'; cvt_lat_s <= '0';
    wait for T;

    ----------------------------------------------------------------
    -- Case 4: WRITE MISS (rw=0, cvt=0)
    -- Expect: decoder_enable=0, output_enable=0, mux_sel=0, mem_enable=0
    ----------------------------------------------------------------
    rw_lat_s <= '0'; cvt_lat_s <= '0';
    wait for T;


    ----------------------------------------------------------------
    -- 4. READ MISS WAIT (100)
    ----------------------------------------------------------------
    state_in_s <= "100";
    wait_cycles(2);

    ----------------------------------------------------------------
    -- 5. READ FETCH (101) - SIMULATE CYCLE FLAGS
    ----------------------------------------------------------------
    state_in_s <= "101";
    report "=== Simulating READFETCH cycles ===" severity note;

    -- (c8neg + c9neg) valid_bit pulse
    wait until falling_edge(clk_s);
    c8n_s <= '1'; wait for CLK_PERIOD/2; c8n_s <= '0';

    wait until falling_edge(clk_s);
    c9n_s <= '1'; wait for CLK_PERIOD/2; c9n_s <= '0';

    -- Byte enable pulses (c9neg, c11neg, c13neg, c15neg)
    wait until falling_edge(clk_s);
    c9n_s <= '1'; wait for CLK_PERIOD/2; c9n_s <= '0';

    wait until falling_edge(clk_s);
    c11n_s <= '1'; wait for CLK_PERIOD/2; c11n_s <= '0';

    wait until falling_edge(clk_s);
    c13n_s <= '1'; wait for CLK_PERIOD/2; c13n_s <= '0';

    wait until falling_edge(clk_s);
    c15n_s <= '1'; wait for CLK_PERIOD/2; c15n_s <= '0';

    -- rw_enable disable windows (c9p, c11p, c13p, c15p)
    wait until rising_edge(clk_s);
    c9p_s <= '1'; wait for CLK_PERIOD/2; c9p_s <= '0';
    wait until rising_edge(clk_s);
    c11p_s <= '1'; wait for CLK_PERIOD/2; c11p_s <= '0';
    wait until rising_edge(clk_s);
    c13p_s <= '1'; wait for CLK_PERIOD/2; c13p_s <= '0';
    wait until rising_edge(clk_s);
    c15p_s <= '1'; wait for CLK_PERIOD/2; c15p_s <= '0';

    ----------------------------------------------------------------
    -- 6. READ DONE (110)
    ----------------------------------------------------------------
    state_in_s <= "110";
    wait_cycles(2);

    ----------------------------------------------------------------
    -- END
    ----------------------------------------------------------------
    report "=== TEST COMPLETE ===" severity note;
    wait for 20 ns;
    assert false severity failure;
  end process;

end behavioral;
