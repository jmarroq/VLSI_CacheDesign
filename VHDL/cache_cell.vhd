-- ==============================================================
-- Entity: cache_cell
-- Author: Juan Marroquin
-- Description:
-- Structural cache cell using cache_sel, Dlatch, tx, and and2.
-- ==============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_cell is
    port (
        CE      : in  std_logic;
        RD_WR   : in  std_logic;
        D_in    : in  std_logic;
        reset   : in  std_logic;
        D_out   : out std_logic
    );
end cache_cell;

architecture structural of cache_cell is

    -- ===== Component Declarations =====
    component cache_sel
        port (
            CE     : in  std_logic;
            RD_WR  : in  std_logic;
            RE     : out std_logic;
            WE     : out std_logic
        );
    end component;

    component tx
        port (
            sel     : in  std_logic;
            selnot  : in  std_logic;
            input   : in  std_logic;
            output  : out std_logic
        );
    end component;

    component Dlatch
        port (
            D   : in  std_logic;
            EN  : in  std_logic;
            Q   : out std_logic;
            Q_n : out std_logic
        );
    end component;

    component and2
        port (
            input1   : in  std_logic;
            input2   : in  std_logic;
            output   : out std_logic
        );
    end component;

    component or2
        port (
            input1   : in  std_logic;
            input2   : in  std_logic;
            output   : out std_logic
        );
    end component;

    component inverter
        port (
            input  : in  std_logic;
            output : out std_logic
        );
    end component;

    -- ===== Internal Signals =====
    signal RE, WE        : std_logic;
    signal RE_bar        : std_logic;
    signal Q_int, Q_n_int: std_logic;
    signal not_reset     : std_logic;
    signal D_for_latch   : std_logic;
    signal EN_for_latch  : std_logic;
    signal read_wire     : std_logic;

begin
    ----------------------------------------------------------------
    -- 1) Cache selector: generates RE and WE
    ----------------------------------------------------------------
    U_SEL : cache_sel
        port map (
            CE     => CE,
            RD_WR  => RD_WR,
            RE     => RE,
            WE     => WE
        );

    ----------------------------------------------------------------
    -- 2) Create reset gating for latch:
    --    When reset='1', latch stores 0 immediately.
    ----------------------------------------------------------------
    U_INV_RST : inverter port map (input => reset, output => not_reset);

    -- D_for_latch = D_in AND (NOT reset)
    U_AND_D : and2 port map (
        input1 => D_in,
        input2 => not_reset,
        output => D_for_latch
    );

    -- EN_for_latch = WE OR reset
    U_OR_EN : or2 port map (
        input1 => WE,
        input2 => reset,
        output => EN_for_latch
    );

    ----------------------------------------------------------------
    -- 3) D latch stores data or clears to 0 on reset
    ----------------------------------------------------------------
    U_LATCH : Dlatch
        port map (
            D   => D_for_latch,
            EN  => EN_for_latch,
            Q   => Q_int,
            Q_n => Q_n_int
        );

    ----------------------------------------------------------------
    -- 4) TX gate for read operation
    ----------------------------------------------------------------
    U_INV_RE : inverter port map (input => RE, output => RE_bar);

    U_TX : tx
        port map (
            sel     => RE,
            selnot  => RE_bar,
            input   => Q_int,
            output  => read_wire
        );

    ----------------------------------------------------------------
    -- 5) Stable output logic
    ----------------------------------------------------------------
    D_out <= '0' when reset = '1' else  Q_int when RE = '1' else 'Z';

end structural;
