-- Entity: mux2to1
-- Architecture: structural
-- Author: jmarroq2
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1 is 
    port(
        S   : in std_logic;
        I0  : in std_logic;
        I1  : in std_logic;
        Y  : out std_logic);
end mux2to1;

architecture structural of mux2to1 is 

component and2
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end component;

component or2
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end component;

component inverter
  port (
    input   : in std_logic;
    output   : out std_logic);
end component;

for and2_1, and2_2: and2 use entity work.and2(structural);
for or2_1: or2 use entity work.or2(structural);
for inverter_1: inverter use entity work.inverter(structural);

signal temp1, temp2, S_not: std_logic;

begin
    inverter_1: inverter port map (S, S_not);
    and2_1: and2 port map (I0, S_not, temp1);
    and2_2: and2 port map (I1, S, temp2);
    or2_1: or2 port map (temp1, temp2, Y);
end structural;
