-- ============================================================
-- Entity: cache_way
-- Author: Juan Marroquin
-- Description:
--   Single way of a 2-way set associative cache.
--   Only contains cache_data_block + tag/valid comparator.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_way is
    port (
        -- Control
        CE_index  : in  std_logic_vector(3 downto 0);
        CE_offset : in  std_logic_vector(3 downto 0);
        RD_WR     : in  std_logic; -- 1=read, 0=write
        reset     : in  std_logic;

        -- Cache block inputs
        Tag_in    : in  std_logic_vector(1 downto 0);
        V_in      : in  std_logic;
        D_in      : in  std_logic_vector(7 downto 0);

        -- Outputs
        D_out     : out std_logic_vector(7 downto 0);
        Tag_out   : out std_logic_vector(1 downto 0);
        V_out     : out std_logic;
        hit       : out std_logic
    );
end cache_way;

architecture structural of cache_way is

begin
    ----------------------------------------------------------------
    -- Cache Data Block
    ----------------------------------------------------------------
    Cache_Block_Inst : entity work.cache_data_block
        port map (
            CE_index  => CE_index,
            CE_offset => CE_offset,
            RD_WR     => RD_WR,
            reset     => reset,
            Tag_in    => Tag_in,
            Tag_out   => Tag_out,
            V_in      => V_in,
            V_out     => V_out,
            D_in      => D_in,
            D_out     => D_out
        );

    ----------------------------------------------------------------
    -- Tag + Valid Comparator
    ----------------------------------------------------------------
    CVT_Inst : entity work.cvt
        port map (
            input1 => Tag_in,
            input2 => Tag_out,
            valid  => V_out,
            output => hit
        );

end architecture;
