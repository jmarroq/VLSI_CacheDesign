--============================================================
-- Entity: cache_byte
-- Author: Juan Marroquin
-- Description:
--   8-bit cache storage block composed of 8 cache_cell units.
--   Each cache_cell has its own bit storage and reset.
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_byte is 
    port (
        CE_index  : in  std_logic;                    
        CE_offset : in  std_logic;                  
        RD_WR     : in  std_logic;                    
        reset     : in  std_logic;                   
        D_in      : in  std_logic_vector(7 downto 0); 
        D_out     : out std_logic_vector(7 downto 0)  
    );
end cache_byte;
  
architecture structural of cache_byte is

    -- Internal signals
    signal CE : std_logic;

begin
    ----------------------------------------------------------------
    -- Combined enable signal
    -- Cell is active only if both index and offset enables are high
    ----------------------------------------------------------------
    chip_enable: entity work.and2(structural)
        port map (
            input1 => CE_index,
            input2 => CE_offset,
            output => CE
        );

    ----------------------------------------------------------------
    -- Generate 8 cache cells (1 per bit)
    ----------------------------------------------------------------
    gen_cell: for i in 0 to 7 generate
        cell_i: entity work.cache_cell(structural)
            port map (
                CE     => CE,
                RD_WR  => RD_WR,
                D_in   => D_in(i),
                reset  => reset,
                D_out  => D_out(i)
            );
    end generate;

end structural;
