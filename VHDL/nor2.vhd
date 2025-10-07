-- Entity: nor2
-- Architecture: structural
-- Author: Juan Marroquin

library IEEE;
use IEEE.std_logic_1164.all;

entity nor2 is
  port (
    input1 : in  std_logic;
    input2 : in  std_logic;
    output : out std_logic
  );
end nor2;

architecture structural of nor2 is

  component or2
    port (
      input1 : in  std_logic;
      input2 : in  std_logic;
      output : out std_logic
    );
  end component;

  component inverter
    port (
      input : in  std_logic;
      output: out std_logic
    );
  end component;

  signal temp: std_logic;
  for or2_1: or2 use entity work.or2(structural);
  for inv1: inverter use entity work.inverter(structural);

begin
  or2_1: or2 port map (input1, input2, temp);
  inv1: inverter port map (temp, output);

end structural;
