-- Entity: decoder2to4.vhd
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity decoder2to4 is 
    port (
        EN    : in std_logic;
        A    : in std_logic_vector(1 downto 0);
        Y  : out std_logic_vector(3 downto 0));
end decoder2to4;

architecture structural of decoder2to4 is

-- REQUIRED COMPONENTS
component and3 is
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    input3   : in  std_logic;
    output   : out std_logic);
end component;
  
component inverter is
  port (
    input    : in  std_logic;
    output   : out std_logic);
end component;

  -- SIGNALS
signal Anot_0 : std_logic;
signal Anot_1 : std_logic;

for and3_1, and3_2, and3_3, and3_4: use entity work.and3(structural);
for inv1, inv2: use entity work.inverter(structural);

begin
    inv1: inverter port map(A(0), Anot_0);
    inv2: inverter port map(A(1), Anot_1);
    and3_1: and3 port map(EN, Anot_0 , A_not1 , Y(O));
    and3_2: and3 port map(EN, A(0), A_not1 , Y(1));
    and3_3: and3 port map(EN, Anot_0 , A(1) , Y(2));
    and3_4: and3 port map(EN, A(0) , A(1) , Y(3));

end structural;
      
  


