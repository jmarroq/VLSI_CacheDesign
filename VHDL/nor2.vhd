-- Entity: nor2
-- Architecture: structural
-- Author: Juan Marroquin
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity nor2 is
  port (
    input1   : in  std_logic;
    input2   : in  std_logic;
    output   : out std_logic);
end not2;

architecture structural of nor2 is
  
begin
  output <= not (input2 or input1);
end structural;
