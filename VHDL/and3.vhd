-- Entity: and3
-- Architecture: structural
-- Author: Juan Marroquin
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity and3 is
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    input3   : in  std_logic;
    output   : out std_logic);
end and3;

architecture structural of and3 is
  
component and2
    port (
      input1 : in  std_logic;
      input2 : in  std_logic;
      output : out std_logic
    );
  end component;

  signal temp: std_logic;
  for and2_1, and2_2: and2 use entity work.and2(structural);

begin
  and2_1: and2 port map (input1, input2, temp);
  and2_2: and2 port map (temp, input3, output);

end structural;
