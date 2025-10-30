-- Entity: positive level triggered D latch
-- Architecture : structural
-- Author: Juan Marroquin
--

library STD;
library IEEE;                      
use IEEE.std_logic_1164.all;       

entity Dlatch is                      
    port (
          D   : in  std_logic;
          EN  : in  std_logic;
          Q   : out std_logic;
          Q_n : out std_logic); 
end Dlatch;                          

architecture structural of Dlatch is 

-- REQUIRED COMPONENTS
component and2
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end component;

component nor2
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

-- SIGNALS
signal D_n, S, R: std_logic;
signal Q_int, Q_n_int: std_logic;

for and2_1, and2_2: and2 use entity work.and2(structural);
for nor2_1, nor2_2: nor2 use entity work.nor2(structural);
for inverter_1: inverter use entity work.inverter(structural);
  
begin
inverter_1: inverter port map(D, D_n);
and2_1: and2 port map(D_n, EN, S);
and2_2: and2 port map(D, EN, R);
nor2_1: nor2 port map(S, Q_n_int, Q_int);
nor2_2: nor2 port map(R, Q_int, Q_n_int);

-- can you do this for structural code / why didnt you just use Q_n and Q in the port mapping
Q_n <= Q_n_int;
Q <= Q_int;

end structural;
