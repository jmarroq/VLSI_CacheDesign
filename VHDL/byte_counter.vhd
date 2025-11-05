library ieee;
use ieee.std_logic_1164.all;

entity byte_counter is
  port(
    clk, reset, enable : in  std_logic;
    byte_cnt_out       : out std_logic_vector(1 downto 0)
  );
end entity;

architecture structural of byte_counter is
  --------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------
  component dff_neg
    port(clk, d, reset : in std_logic; q : out std_logic);
  end component;
  component and2     port (input1,input2: in std_logic; output: out std_logic); end component;
  component or2      port (input1,input2: in std_logic; output: out std_logic); end component;
  component inverter port (input: in std_logic; output: out std_logic); end component;

  --------------------------------------------------------------------
  -- Internal Signals
  --------------------------------------------------------------------
  signal Q0, Q1          : std_logic := '0';
  signal nQ0, nQ1        : std_logic;
  signal nEn, c1         : std_logic;
  signal x0a, x0b, x1a, x1b : std_logic;
  signal D0, D1          : std_logic;

begin
  --------------------------------------------------------------------
  -- Inverters
  --------------------------------------------------------------------
  inv_en : inverter port map(enable, nEn);
  inv_q0 : inverter port map(Q0, nQ0);
  inv_q1 : inverter port map(Q1, nQ1);

  --------------------------------------------------------------------
  -- Carry chain: c1 = enable AND Q0
  --------------------------------------------------------------------
  and_c1 : and2 port map(enable, Q0, c1);

  --------------------------------------------------------------------
  -- Bit 0 XOR (Q0 XOR enable)
  --------------------------------------------------------------------
  and_x00 : and2 port map(Q0, nEn, x0a);
  and_x01 : and2 port map(nQ0, enable, x0b);
  or_x0   : or2  port map(x0a, x0b, D0);

  --------------------------------------------------------------------
  -- Bit 1 XOR (Q1 XOR c1)
  --------------------------------------------------------------------
  inv_c1  : inverter port map(c1, nEn);
  and_x10 : and2 port map(Q1, not c1, x1a);
  and_x11 : and2 port map(nQ1, c1, x1b);
  or_x1   : or2  port map(x1a, x1b, D1);

  --------------------------------------------------------------------
  -- D Flip-Flops (negative edge, active-high reset)
  --------------------------------------------------------------------
  ff0 : dff_neg port map(clk => clk, d => D0, reset => reset, q => Q0);
  ff1 : dff_neg port map(clk => clk, d => D1, reset => reset, q => Q1);

  --------------------------------------------------------------------
  -- Output
  --------------------------------------------------------------------
  byte_cnt_out <= Q1 & Q0;

end structural;
