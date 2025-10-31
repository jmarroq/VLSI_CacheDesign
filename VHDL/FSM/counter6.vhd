library ieee;
use ieee.std_logic_1164.all;

entity counter6 is
  port(
    clk   : in  std_logic;
    reset : in  std_logic;  
    en    : in  std_logic;
    q_out : out std_logic_vector(5 downto 0)
  );
end entity;

architecture structural of counter6 is
  --------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------
  component dff_pos port(clk, d, reset: in std_logic; q: out std_logic); end component;
  component and2 port(input1, input2: in std_logic; output: out std_logic); end component;
  component or2 port(input1, input2: in std_logic; output: out std_logic); end component;
  component xor2 port(input1, input2: in std_logic; output: out std_logic); end component;

  --------------------------------------------------------------------
  -- Internal Signals
  --------------------------------------------------------------------
  signal q, next_q : std_logic_vector(5 downto 0);
  signal c0, c1, c2, c3, c4 : std_logic;

begin
  -- ripple-carry chain
  and_c0 : and2 port map(en, q(0), c0);
  and_c1 : and2 port map(c0, q(1), c1);
  and_c2 : and2 port map(c1, q(2), c2);
  and_c3 : and2 port map(c2, q(3), c3);
  and_c4 : and2 port map(c3, q(4), c4);

  -- structural XOR chain (increment by 1)
  xor0_i : xor2 port map(q(0), en,  next_q(0));
  xor1_i : xor2 port map(q(1), c0,  next_q(1));
  xor2_i : xor2 port map(q(2), c1,  next_q(2));
  xor3_i : xor2 port map(q(3), c2,  next_q(3));
  xor4_i : xor2 port map(q(4), c3,  next_q(4));
  xor5_i : xor2 port map(q(5), c4,  next_q(5));


  -- flip-flops
  dff0 : dff_pos port map(clk, next_q(0), reset, q(0));
  dff1 : dff_pos port map(clk, next_q(1), reset, q(1));
  dff2 : dff_pos port map(clk, next_q(2), reset, q(2));
  dff3 : dff_pos port map(clk, next_q(3), reset, q(3));
  dff4 : dff_pos port map(clk, next_q(4), reset, q(4));
  dff5 : dff_pos port map(clk, next_q(5), reset, q(5));

  q_out <= q;

end architecture;

