--============================================================
-- Entity: valid_bit
-- Author: Juan Marroquin
-- Description:
--   1-bit valid flag storage using a single cache_cell.
--   Clears to 0 on reset.
--============================================================

library IEEE;
use IEEE.std_logic_1164.all;	 

entity valid_bit is
    port (
        CE     : in  std_logic;   
        RD_WR  : in  std_logic;   
        reset  : in  std_logic;   
        V_in   : in  std_logic;   
        V_out  : out std_logic    
    );
end valid_bit;

architecture structural of valid_bit is

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
    -- Single cache_cell instance for the valid bit
    ----------------------------------------------------------------
    cache_cell_inst: cache_cell
        port map (
            CE     => CE,
            RD_WR  => RD_WR,
            D_in   => V_in,
            reset  => reset,
            D_out  => V_out
        );

end structural;
