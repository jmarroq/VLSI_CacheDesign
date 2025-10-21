-- 2 inputs (d, clk) 2 outputs (q, )
-- 2 dlatch, 2 inverters
-- Entity: positive level triggered D FF
-- Architecture : structural
-- Author: Hannah Mathew
--

library STD;
library IEEE;                      
use IEEE.std_logic_1164.all;       

entity Dff is                      
    port (
          D   : in  std_logic;
          CLK  : in  std_logic;
          Q   : out std_logic;
          Q_n : out std_logic); 
end Dff;              

architecture structural of Dff is 
component inverter
  port (
    input    : in std_logic;
    output   : out std_logic);
end component;

component Dlatch
port (
          D   : in  std_logic;
          EN  : in  std_logic;
          Q   : out std_logic;
          Q_n : out std_logic); 
end component;   

signal EN1, EN2, Q1, Q_n1: std_logic;
-- inverters
for inv1: inverter use entity work.inverter(structural);
for inv2: inverter use entity work.inverter(structural);

-- Dlatches
for Dlatch_1: Dlatch use entity work.Dlatch(structural);
for Dlatch_2: Dlatch use entity work.Dlatch(structural);

begin
inv1: inverter port map(CLK,EN1);
inv1: inverter port map(EN1,EN2);

Dlatch_1: Dlatch port map(D, EN1, Q1, Q_n1);
Dlatch_2: Dlatch port map(Q1, EN2, Q, Q_n);

end structural;


