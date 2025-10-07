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

begin
  output <= input2 and input1 and input3;
end structural;
