-- Entity: valid bit
-- Architecture: structural
-- Author: Juan Marroquin
--
library STD;
library IEEE;
use IEEE.std_logic_1164.all;	 

entity valid_bit is
	port (
    	CE 	: in std_logic;
    	RD_WR  : in std_logic;
    	V_in   : in std_logic;
    	V_out  : out std_logic);
end valid_bit;


architecture structural of valid_bit is

-- REQUIRED COMPONENTS
component cache_cell is
	port (
    	CE 	: in std_logic;
    	RD_WR  : in std_logic;
    	D_in   : in std_logic;
    	D_out  : out std_logic);
end component;
--for cache_cell_inst: cache_cell use entity work.cache_cell(structural);

begin
 
	cache_cell_inst: cache_cell port map(CE, RD_WR, V_in , V_out);
    
end structural;
