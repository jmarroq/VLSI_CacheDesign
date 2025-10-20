-- Entity: xor2
-- Architecture: structural
-- Author: hmathew1
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity xor2 is
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end xor2;

architecture structural of xor2 is

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

component and2 is
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic
    );
end component;

signal A_not, B_not, AnotB, AnotB: std_logic;
  for inverter_1: inverter use entity work.inverter(structural);
  for inverter_2: inverter use entity work.inverter(structural);
  for and2_ABnot: and2 use entity work.and2(structural);
  for and2_AnotB: and2 use entity work.and2(structural);
  for or2_1: or2 use entity work.or2(structural);

begin
    -- get inverted A and B
  inverter_1: inverter port map (input1, A_not);
  inverter_2: inverter port map (input2, B_not);

  and2_ABnot: and2 port map (A, B_not, ABnot);
  and2_AnotB: and2 port map (A_not, B, AnotB);

  or2_1: or2 port map (ABnot, AnotB, output);

end structural;