--============================================================
-- Entity: cache_line_data
-- Author: Juan Marroquin
-- Description:
--   4-byte cache line composed of 4 cache_byte blocks.
--   Each cache_byte corresponds to one offset bit position.
--   The line clears entirely on reset.
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_line_data is 
    port (
        CE_index  : in  std_logic;                      
        CE_offset : in  std_logic_vector(3 downto 0);   
        RD_WR     : in  std_logic;                     
        reset     : in  std_logic;                     
        D_in      : in  std_logic_vector(7 downto 0);   
        D_out     : out std_logic_vector(7 downto 0)   
    );
end cache_line_data;

architecture structural of cache_line_data is
begin

    ----------------------------------------------------------------
    -- Generate 4 cache_byte blocks (one per byte in the cache line)
    ----------------------------------------------------------------
    gen_byte: for i in 0 to 3 generate
        byte_i: entity work.cache_byte(structural)
            port map (
                CE_index  => CE_index,
                CE_offset => CE_offset(i),
                RD_WR     => RD_WR,
                reset     => reset,
                D_in      => D_in,
                D_out     => D_out
            );
    end generate;

end structural;
