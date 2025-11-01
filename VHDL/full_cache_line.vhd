--============================================================
-- Entity: full_cache_line
-- Author: Juan Marroquin
-- Description:
--   Complete cache line containing:
--     - Data array (4 bytes = 1 line)
--     - Tag block (2 bits)
--     - Valid bit block (1 bit)
--   Includes asynchronous reset propagated to all submodules.
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity full_cache_line is 
    port (
        CE_index  : in  std_logic;                      
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
end full_cache_line;

architecture structural of full_cache_line is

    ----------------------------------------------------------------
    -- Components
    ----------------------------------------------------------------
    component and2
        port (
            input1 : in  std_logic;
            input2 : in  std_logic;
            output : out std_logic
        );
    end component;

    component inverter
        port (
            input  : in  std_logic;
            output : out std_logic
        );
    end component;

    ----------------------------------------------------------------
    -- Internal signals
    ----------------------------------------------------------------
    signal RD_WR_n       : std_logic;
    signal CE_tag_valid  : std_logic;
    signal CE_tag_base   : std_logic;

begin
    ----------------------------------------------------------------
    -- Invert RD_WR
    ----------------------------------------------------------------
    inv_rdwr: inverter port map (
        input  => RD_WR,
        output => RD_WR_n
    );

    ----------------------------------------------------------------
    -- Generate combined enable for tag/valid section
    ----------------------------------------------------------------
    and2_base: and2 port map (
        input1 => CE_index,
        input2 => CE_offset(0),
        output => CE_tag_base
    );

    CE_tag_valid <= CE_tag_base;

    ----------------------------------------------------------------
    -- Data array (4-byte line)
    ----------------------------------------------------------------
    cache_line_data_inst: entity work.cache_line_data(structural)
        port map (
            CE_index  => CE_index,
            CE_offset => CE_offset,
            RD_WR     => RD_WR,
            reset     => reset,
            D_in      => D_in,
            D_out     => D_out
        );

    ----------------------------------------------------------------
    -- Tag storage (2-bit, with reset)
    ----------------------------------------------------------------
    tag_inst: entity work.tag(structural)
        port map (
            CE      => CE_tag_valid,
            RD_WR   => RD_WR,
            reset   => reset,
            Tag_in  => Tag_in,
            Tag_out => Tag_out
        );

    ----------------------------------------------------------------
    -- Valid-bit storage (1-bit, with reset)
    ----------------------------------------------------------------
    valid_bit_inst: entity work.valid_bit(structural)
        port map (
            CE     => CE_tag_valid,
            RD_WR  => RD_WR,
            reset  => reset,
            V_in   => V_in,
            V_out  => V_out
        );

end structural;
