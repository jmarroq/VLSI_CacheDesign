--
library ieee;
use ieee.std_logic_1164.all;

entity lru_logic is
    port(
        clk       : in  std_logic;
        reset     : in  std_logic;
        rd_wrn    : in  std_logic;  -- 1=read, 0=write
        hit_way0  : in  std_logic;
        hit_way1  : in  std_logic;
        LRU_out   : out std_logic
    );
end entity;

architecture structural of lru_logic is

    -- Internal signals
    signal D_in      : std_logic;
    signal LRU_bit   : std_logic;
    signal way0_miss : std_logic;
    signal way1_miss : std_logic;
    signal rd_wrn_n  : std_logic;
    signal term0, term1, term2 : std_logic;

begin

    ----------------------------------------------------------------
    -- Compute misses
    ----------------------------------------------------------------
    way0_miss <= not hit_way0;
    way1_miss <= not hit_way1;

    ----------------------------------------------------------------
    -- Invert rd_wrn for active-low write detection
    ----------------------------------------------------------------
    rd_wrn_n <= not rd_wrn;

    ----------------------------------------------------------------
    -- Gate-level logic for D input to DFF
    ----------------------------------------------------------------
    term0 <= way0_miss and rd_wrn_n;
    term1 <= way1_miss and rd_wrn_n;
    term2 <= (not term0) and (not term1) and LRU_bit;
    D_in  <= term0 or term1 or term2;

    ----------------------------------------------------------------
    -- DFF to store LRU state
    ----------------------------------------------------------------
    LRU_DFF : entity work.dff_pos
        port map(
            clk   => clk,
            d     => D_in,
            reset => reset,
            q     => LRU_bit
        );

    ----------------------------------------------------------------
    -- Output
    ----------------------------------------------------------------
    LRU_out <= LRU_bit;

end architecture;

  
