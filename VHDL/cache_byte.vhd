-- Entity: cache_cell
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_byte is 
    port (
        CE     : in std_logic;
        RD_WR  : in std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end cache_byte;
  
architecture structural of cache_byte is

-- REQUIRED COMPONENTS
component cache_cell is 
    port (
        CE     : in std_logic;
        RD_WR  : in std_logic;
        D_in   : in std_logic;
        D_out  : out std_logic);
end component;

for cache_cell_inst: cache_cell use entity work.cache_cell(structural);

begin
    gen_cell: for i in 0 to 7 generate
      cell_i: cache_cell port map
        (
        CE     => CE,
        RD_WR  => RD_WR,
        D_in   => D_in(i),
        D_out  => D_out(i)
          );
  end generate;
end structural;
  
