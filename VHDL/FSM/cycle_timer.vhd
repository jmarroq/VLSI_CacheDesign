library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cycle_timer is
  port(
    clk, reset, busy : in  std_logic;

    -- POS-edge flags (combinational, same-cycle)
    c0_pos, c1_pos, c9_pos, c11_pos, c13_pos, c15_pos : out std_logic;

    -- NEG-edge flags (registered for half-cycle offset)
    c0_neg, c8_neg, c9_neg, c11_neg, c13_neg, c15_neg, c16_neg : out std_logic
  );
end entity;

architecture structural of cycle_timer is
  --------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------
  component and2     port(input1,input2: in std_logic; output: out std_logic); end component;
  component dff_pos  port(clk,d,reset: in std_logic; q: out std_logic); end component;
  component dff_neg  port(clk,d,reset: in std_logic; q: out std_logic); end component;
  component eq6bit
    port(a, b: in std_logic_vector(5 downto 0); y: out std_logic);
  end component;
  component counter6
    port(clk, reset, en: in std_logic; q_out: out std_logic_vector(5 downto 0));
  end component;

  --------------------------------------------------------------------
  -- Internal signals
  --------------------------------------------------------------------
  signal cnt       : std_logic_vector(5 downto 0);
  signal busy_sync : std_logic;

  -- Equality comparisons (raw)
  signal eq0, eq1, eq8, eq9, eq11, eq13, eq15, eq16 : std_logic;

  -- NEG-edge registered flags
  signal c0n, c8n, c9n, c11n, c13n, c15n, c16n : std_logic;

begin
  --------------------------------------------------------------------
  -- SYNCHRONIZE BUSY TO POSEDGE
  --------------------------------------------------------------------
  sync_busy : dff_pos port map(clk, busy, reset, busy_sync);

  --------------------------------------------------------------------
  -- MAIN COUNTER
  --------------------------------------------------------------------
  cnt_u : counter6 port map(clk => clk, reset => reset, en => busy_sync, q_out => cnt);

  --------------------------------------------------------------------
  -- COMPARATORS 
  --------------------------------------------------------------------
  eq0_u  : eq6bit port map(cnt, std_logic_vector(to_unsigned(0,6)),  eq0);
  eq1_u  : eq6bit port map(cnt, std_logic_vector(to_unsigned(1,6)),  eq1);
  eq8_u  : eq6bit port map(cnt, std_logic_vector(to_unsigned(8,6)),  eq8);
  eq9_u  : eq6bit port map(cnt, std_logic_vector(to_unsigned(9,6)),  eq9);
  eq11_u : eq6bit port map(cnt, std_logic_vector(to_unsigned(11,6)), eq11);
  eq13_u : eq6bit port map(cnt, std_logic_vector(to_unsigned(13,6)), eq13);
  eq15_u : eq6bit port map(cnt, std_logic_vector(to_unsigned(15,6)), eq15);
  eq16_u : eq6bit port map(cnt, std_logic_vector(to_unsigned(16,6)), eq16);

  --------------------------------------------------------------------
  -- POS-EDGE FLAGS (direct)
  --------------------------------------------------------------------
  c0_pos  <= eq0;
  c1_pos  <= eq1;
  c9_pos  <= eq9;
  c11_pos <= eq11;
  c13_pos <= eq13;
  c15_pos <= eq15;

  --------------------------------------------------------------------
  -- NEG-EDGE FLAGS (half-cycle later)
  --------------------------------------------------------------------
  c0n_ff  : dff_neg port map(clk, eq0,  reset, c0n);
  c8n_ff  : dff_neg port map(clk, eq8,  reset, c8n);
  c9n_ff  : dff_neg port map(clk, eq9,  reset, c9n);
  c11n_ff : dff_neg port map(clk, eq11, reset, c11n);
  c13n_ff : dff_neg port map(clk, eq13, reset, c13n);
  c15n_ff : dff_neg port map(clk, eq15, reset, c15n);
  c16n_ff : dff_neg port map(clk, eq16, reset, c16n);

  --------------------------------------------------------------------
  -- OUTPUT ASSIGNMENTS
  --------------------------------------------------------------------
  c0_neg <= c0n;
  c8_neg <= c8n;
  c9_neg <= c9n;
  c11_neg <= c11n;
  c13_neg <= c13n;
  c15_neg <= c15n;
  c16_neg <= c16n;

end structural;
