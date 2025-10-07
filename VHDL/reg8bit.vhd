-- Entity: 8-bit register
-- Architecture: structural
-- Author: Juan Marroquin

library IEEE;
use IEEE.std_logic_1164.all;

entity reg8 is
  port (
    D    : in  std_logic_vector(7 downto 0);
    CLK  : in  std_logic;
    RESET: in  std_logic;
    Q    : out std_logic_vector(7 downto 0)
  );
end reg8;

architecture structural of reg8 is

  component d_ff
    port (
      D    : in  std_logic;
      CLK  : in  std_logic;
      RESET: in  std_logic;
      Q    : out std_logic
    );
  end component;

  for d_ff_inst: d_ff use entity work.d_ff(structural);

begin

  gen_ff: for i in 0 to 7 generate
    ff_i: d_ff port map (
      D     => D(i),
      CLK   => CLK,
      RESET => RESET,
      Q     => Q(i)
    );
  end generate;

end structural;
