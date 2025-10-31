-- Entity: tag cells
-- Architecture: structural
-- Author: Juan Marroquin
--

library STD;
library IEEE;
use IEEE.std_logic_1164.all;	 


entity tag is
	port (
    	CE 	: in std_logic;
    	RD_WR  : in std_logic;
    	Tag_in   : in std_logic_vector(1 downto 0);
    	Tag_out  : out std_logic_vector(1 downto 0));
end tag;

architecture structural of tag is

	-- REQUIRED COMPONENTS
	component cache_cell is
    	port (
    	CE 	: in std_logic;
    	RD_WR  : in std_logic;
    	D_in   : in std_logic;
    	D_out  : out std_logic);
	end component;

	begin
  	gen_cell: for i in 0 to 1 generate
    	cell_i: cache_cell port map
      	(
      	CE 	=> CE,
      	RD_WR  => RD_WR,
      	D_in   => Tag_in(i),
      	D_out  => Tag_out(i)
        	);
    	end generate;
end structural;

