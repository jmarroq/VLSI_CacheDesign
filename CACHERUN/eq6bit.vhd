
library ieee;
use ieee.std_logic_1164.all;

entity eq6bit is
  port(
    a, b : in  std_logic_vector(5 downto 0);
    y    : out std_logic
  );
end entity;

architecture structural of eq6bit is
  --------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------
  component xnor2 port(input1, input2 : in std_logic; output : out std_logic); end component;
  component and3 port(input1, input2, input3 : in std_logic; output : out std_logic); end component;
  component and2 port(input1, input2 : in std_logic; output : out std_logic); end component;

  --------------------------------------------------------------------
  -- Internal signals
  --------------------------------------------------------------------
  signal xnor_bits : std_logic_vector(5 downto 0);
  signal p0, p1    : std_logic;

begin
  --------------------------------------------------------------------
  -- Bitwise XNORs
  --------------------------------------------------------------------
  xnor0_i : xnor2 port map(a(0), b(0), xnor_bits(0));
  xnor1_i : xnor2 port map(a(1), b(1), xnor_bits(1));
  xnor2_i : xnor2 port map(a(2), b(2), xnor_bits(2));
  xnor3_i : xnor2 port map(a(3), b(3), xnor_bits(3));
  xnor4_i : xnor2 port map(a(4), b(4), xnor_bits(4));
  xnor5_i : xnor2 port map(a(5), b(5), xnor_bits(5));

  --------------------------------------------------------------------
  -- Combine groups of bits
  --------------------------------------------------------------------
  and_low  : and3 port map(xnor_bits(0), xnor_bits(1), xnor_bits(2), p0);
  and_high : and3 port map(xnor_bits(3), xnor_bits(4), xnor_bits(5), p1);
  and_all  : and2 port map(p0, p1, y);

end architecture;
