-- Entity: xor2
-- Architecture: structural
-- Author: hmathew1
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity xnor2 is
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end xnor2;

architecture structural of xnor2 is

    component xor2
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
  for xnor2_1: xor2 use entity work.xor2(structural);
  for inv1: inverter use entity work.inverter(structural);

begin
  xor2_1: xor2 port map (input1, input2, temp);
  inv1: inverter port map (temp, output);

end structural;
