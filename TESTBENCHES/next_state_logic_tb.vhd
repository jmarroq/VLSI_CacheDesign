library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity next_state_logic_tb is
end next_state_logic_tb;

architecture behavioral of next_state_logic_tb is

  component next_state_logic
    port(
      state_in   : in  std_logic_vector(2 downto 0);
      start      : in  std_logic;
      rw_lat     : in  std_logic;
      cvt_lat    : in  std_logic;
      c18        : in  std_logic;
      next_state : out std_logic_vector(2 downto 0)
    );
  end component;

  -- signals
  signal state_in_s   : std_logic_vector(2 downto 0) := (others => '0');
  signal start_s, rw_s, cvt_s, c18_s : std_logic := '0';
  signal next_state_s : std_logic_vector(2 downto 0);

  
begin
  --------------------------------------------------------------------
  -- UUT
  --------------------------------------------------------------------
  uut: next_state_logic
    port map(
      state_in   => state_in_s,
      start      => start_s,
      rw_lat     => rw_s,
      cvt_lat    => cvt_s,
      c18        => c18_s,
      next_state => next_state_s
    );

  --------------------------------------------------------------------
  -- Stimulus process
  --------------------------------------------------------------------
  stim: process
  begin
    ------------------------------------------------------------------
    -- 1. IDLE (000) → IDLE (000) when start=0
    ------------------------------------------------------------------
    state_in_s <= "000"; start_s <= '0';
    rw_s <= '0'; cvt_s <= '0'; c18_s <= '0';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 2. IDLE (000) → LATCH (001) when start=1
    ------------------------------------------------------------------
    state_in_s <= "000"; start_s <= '1';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 3. LATCH (001) → DECIDE (010)
    ------------------------------------------------------------------
    state_in_s <= "001"; start_s <= '0';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 4. DECIDE (010) → WRITE WAIT (011) when rw=0
    ------------------------------------------------------------------
    state_in_s <= "010"; rw_s <= '0'; cvt_s <= '0';
    wait for 1 ns;
   
   

    ------------------------------------------------------------------
    -- 5. DECIDE (010) → IDLE (000) when rw=1, cvt=1 (read hit)
    ------------------------------------------------------------------
    state_in_s <= "010"; rw_s <= '1'; cvt_s <= '1';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 6. DECIDE (010) → READ MISS WAIT (100) when rw=1, cvt=0
    ------------------------------------------------------------------
    state_in_s <= "010"; rw_s <= '1'; cvt_s <= '0';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 7. READ MISS WAIT (100) → READ FETCH (101)
    ------------------------------------------------------------------
    state_in_s <= "100";
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 8. READ FETCH (101) → READ FETCH (101) when c18=0
    ------------------------------------------------------------------
    state_in_s <= "101"; c18_s <= '0';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 9. READ FETCH (101) → READ DONE (110) when c18=1
    ------------------------------------------------------------------
    state_in_s <= "101"; c18_s <= '1';
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 10. READ DONE (110) → IDLE (000)
    ------------------------------------------------------------------
    state_in_s <= "110";
    wait for 1 ns;
    

    ------------------------------------------------------------------
    -- 11. WRITE WAIT (011) → IDLE (000)
    ------------------------------------------------------------------
    state_in_s <= "011";
    wait for 1 ns;
   

    -- End simulation
    wait for 10 ns;
    assert false severity failure;
  end process;

end behavioral;
