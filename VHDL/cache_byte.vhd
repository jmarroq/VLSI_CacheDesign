-- Entity: cache_byte
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_byte is
	port (
    	CE_index 	: in std_logic;
    	CE_offset	: in std_logic;
    	RD_WR  : in std_logic;
    	D_in   : in std_logic_vector(7 downto 0);
    	D_out  : out std_logic_vector(7 downto 0));
end cache_byte;
 
architecture structural of cache_byte is

-- REQUIRED COMPONENTS
component cache_cell is
	port (
    	CE 	: in std_logic;
    	RD_WR  : in std_logic;
    	D_in   : in std_logic;
    	D_out  : out std_logic);
end component;
    
component and2
  port (
	input1   : in  std_logic;
	input2   : in  std_logic;
	output   : out std_logic);
end component;


signal CE : std_logic;

begin
	chip_enable: entity work.and2(structural)
    	port map(CE_index, CE_offset, CE);

	gen_cell: for i in 0 to 7 generate
    	cell_i: entity work.cache_cell(structural)
        	port map(
            	CE 	=> CE,
            	RD_WR  => RD_WR,
            	D_in   => D_in(i),
            	D_out  => D_out(i)
        	);
	end generate;
end structural;



