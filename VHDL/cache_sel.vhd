-- Entity: cache_sel -  Cache Cell selector
-- Architecture : structural
-- Author: Juan Marroquin
--
library STD;
library IEEE;                      
use IEEE.std_logic_1164.all;       

entity cache_sel is
    port(  
        CE      : in std_logic;
        RD_WR   : in std_logic;
        RE      : in std_logic;
        WE      : in std_logic);
end cache_sel;
  
architecture structural of cache_sel is

-- REQUIRED COMPONENTS
component and2
    port (
      input1   : in  std_logic;
      input2   : in  std_logic;
      output   : out std_logic);
    end component;

  component inverter 
  port (
    input    : in  std_logic;
    output   : out std_logic);
  end component;

-- SIGNALS
signal RD_WR_not  : std_logic;

for and2_1, and2_2: and2 use entity work.and2(structural);
for inverter_1: inverter use entity work.inverter(structural);

begin 
  inverter_1: inverter port map (RD_WR, RD_WR_not);
  and2_1: and2 port map (CE, RD_WR, RE);
  and2_2: and2 port map (CE, RD_WR_not, WE);
end structural;
  
  
  

  
