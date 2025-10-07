-- Entity: 2_bit comparator
-- Architecture: structural
-- Author: Juan Marroquin
--
library IEEE;
use IEEE.std_logic_1164.all;

entity cmp2 is
  port (
    A  : in  std_logic_vector(1 downto 0);
    B  : in  std_logic_vector(1 downto 0);
    EQ : out std_logic
  );
end cmp2;

architecture structural of cmp2 is 

-- REQUIRED COMPONENTS
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


  for invA0, invA1, invB0, invB1: inverter use entity work.inverter(structural);
  for and0a, and0b, and1a, and1b, andFinal: and2 use entity work.and2(structural);
  for or0, or1: or2 use entity work.or2(structural);
  
 -- intermediate signals
  signal notA0, notA1, notB0, notB1: std_logic;
  signal bit0_eq, bit1_eq: std_logic;
  signal t1, t2, t3, t4: std_logic;

begin

  -- invert inputs
  invA0: inverter port map (A(0), notA0);
  invA1: inverter port map (A(1), notA1);
  invB0: inverter port map (B(0), notB0);
  invB1: inverter port map (B(1), notB1);

  -- bit0 equality: (A0 AND B0) OR (~A0 AND ~B0)
  and0a: and2 port map (A(0), B(0), t1);
  and0b: and2 port map (notA0, notB0, t2);
  or0:  or2  port map (t1, t2, bit0_eq);

  -- bit1 equality: (A1 AND B1) OR (~A1 AND ~B1)
  and1a: and2 port map (A(1), B(1), t3);
  and1b: and2 port map (notA1, notB1, t4);
  or1:  or2  port map (t3, t4, bit1_eq);

  -- final equality
  andFinal: and2 port map (bit0_eq, bit1_eq, EQ);

end structural;
  
  
