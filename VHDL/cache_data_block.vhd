--============================================================
-- Entity: cache_data_block
-- Author: Juan Marroquin
-- Description:
--   4-line cache data array, each line consisting of:
--     - 4-byte data section
--     - 2-bit tag
--     - 1-bit valid flag
--   Includes asynchronous reset propagation to all lines.
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_data_block is
    port (
        CE_index  : in  std_logic_vector(3 downto 0);  
        CE_offset : in  std_logic_vector(3 downto 0);   
        RD_WR     : in  std_logic;                      
        reset     : in  std_logic;                      
        Tag_in    : in  std_logic_vector(1 downto 0);   
        Tag_out   : out std_logic_vector(1 downto 0);   
        V_in      : in  std_logic;                      
        V_out     : out std_logic;                      
        D_in      : in  std_logic_vector(7 downto 0);   
        D_out     : out std_logic_vector(7 downto 0)    
    );
end cache_data_block;

architecture structural of cache_data_block is
begin

    ----------------------------------------------------------------
    -- Generate 4 full_cache_line blocks (one per index line)
    ----------------------------------------------------------------
    gen_lines: for i in 0 to 3 generate
        line_inst: entity work.full_cache_line(structural)
            port map (
                CE_index  => CE_index(i),  -- one index enable per line
                CE_offset => CE_offset,    -- shared offset select
                RD_WR     => RD_WR,
                reset     => reset,
                Tag_in    => Tag_in,
                Tag_out   => Tag_out,
                V_in      => V_in,
                V_out     => V_out,
                D_in      => D_in,
                D_out     => D_out
            );
    end generate gen_lines;

end structural;
