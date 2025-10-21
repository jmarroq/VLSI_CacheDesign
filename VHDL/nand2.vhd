-- Entity: nor2
-- Architecture: structural
-- Author: Hannah Mathew

library IEEE;
use IEEE.std_logic_1164.all;

entity nand2 is
  port (
    input1 : in  std_logic;
    input2 : in  std_logic;
    output : out std_logic
  );
end nand2;

architecture structural of nand2 is

  component and2
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
  for and2_1: and2 use entity work.and2(structural);
  for inv1: inverter use entity work.inverter(structural);

begin
  and2_1: and2 port map (input1, input2, temp);
  inv1: inverter port map (temp, output);

end structural;
