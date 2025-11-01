--============================================================
-- Entity: tag
-- Author: Juan Marroquin
-- Description:
--   2-bit tag storage block composed of two cache_cell units.
--   Each cache_cell stores one tag bit and clears to 0 on reset.
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity tag is
    port (
        CE      : in  std_logic;                    
        RD_WR   : in  std_logic;                    
        reset   : in  std_logic;                   
        Tag_in  : in  std_logic_vector(1 downto 0); 
        Tag_out : out std_logic_vector(1 downto 0) 
    );
end tag;

architecture structural of tag is

    ----------------------------------------------------------------
    -- Components
    ----------------------------------------------------------------
    component cache_cell is
        port (
            CE     : in  std_logic;
            RD_WR  : in  std_logic;
            D_in   : in  std_logic;
            reset  : in  std_logic;
            D_out  : out std_logic
        );
    end component;

begin
    ----------------------------------------------------------------
    -- Generate 2 cache cells (1 per tag bit)
    ----------------------------------------------------------------
    gen_cell: for i in 0 to 1 generate
        cell_i: cache_cell
            port map (
                CE     => CE,
                RD_WR  => RD_WR,
                D_in   => Tag_in(i),
                reset  => reset,
                D_out  => Tag_out(i)
            );
    end generate;

end structural;
