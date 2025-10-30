library ieee;
use ieee.std_logic_1164.all;

entity or4 is
  port(
    input1, input2, input3, input4 : in  std_logic;
    output : out std_logic
  );
end or4;

architecture structural of or4 is
  component or2
    port(input1, input2: in std_logic; output: out std_logic);
  end component;

  signal or_a, or_b : std_logic;
begin
  o1 : or2 port map(input1, input2, or_a);
  o2 : or2 port map(input3, input4, or_b);
  o3 : or2 port map(or_a, or_b, output);
end structural;
