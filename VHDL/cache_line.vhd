-- Entity: cache_line
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_line is 
    port (
        CE_index     : in std_logic;
        CE_offset    : in std_logic_vector(3 downto 0);
        RD_WR  : in std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end cache_line;

architecture structural of cache_line is

-- REQUIRED COMPONENTS
components cache_byte is 
    port (
        CE_index     : in std_logic;
        CE_offset    : in std_logic;
        RD_WR  : in std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end cache_byte;  

for cache_byte_inst: cache_byte use entity work.cache_byte(structural);

begin
    gen_byte: for i on 0 to 3 generate
        byte_i: cache_byte  port map
        (
        CE_index     => CE_index,
        CE_offset    => CE_offset(i),
        RD_WR  =>  RD_WR,
        D_in   => D_in,
        D_out  => D_out
          );
end generate;
end structural;
