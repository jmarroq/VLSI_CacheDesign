-- Entity: cache_cell
-- Architecture: structural
-- Author: Juan Marroquin

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_cell_sr is
	port (
    	CE 	: in std_logic;
    	RD_WR  : in std_logic;
		reset	: in std_logic;
    	D_in   : in std_logic;
    	D_out  : out std_logic);
end cache_cell_sr;
architecture structural of cache_cell_sr is
  
-- REQUIRED COMPONENTS
component cache_sel
    port (
        CE      : in  std_logic;
        RD_WR   : in  std_logic;
        RE      : out std_logic;
        WE      : out std_logic);
end component;

component sr_latch
    port (
        S      : in  std_logic;
        R      : in  std_logic;
        Q      : out std_logic;
        Q_n    : out std_logic);
end component;

component tx
    port (
        sel      : in  std_logic;
        selnot   : in  std_logic;
        input    : in  std_logic;
        output   : out std_logic);
end component;

component inverter
    port (
        input    : in  std_logic;
        output   : out std_logic);
end component;

-- SIGNALS
signal RE_signal, WE_signal : std_logic;
signal RE_bar               : std_logic;
signal Q_int, Q_n_int       : std_logic;

-- SR Latch control signals
signal reset_latch   : std_logic := '0';  -- Reset signal for the latch
signal set_latch     : std_logic := '0';  -- Set signal for the latch

begin
    -- Cache Selector (no reset handling needed here)
    cache_selector1: cache_sel
        port map (CE, RD_WR, RE_signal, WE_signal);
    
    -- SR Latch (this is where we reset the latch if reset is high)
    sr_latch1: sr_latch
        port map (S => set_latch, R => reset_latch, Q => Q_int, Q_n => Q_n_int);
    
    -- Inverter (no reset handling needed here, just passing signals)
    inverter1: inverter
        port map (RE_signal, RE_bar);
    
    -- TX logic (no reset handling needed here, just passing signals)
    tx1: tx
        port map (RE_signal, RE_bar, Q_int, D_out);

    -- Control the reset and set logic (for the SR latch)
    process(reset, RD_WR)
    begin
        -- Active high reset
        if reset = '1' then
            reset_latch <= '1';  -- Activate reset for SR latch
            set_latch <= '0';    -- Ensure set is not active during reset
        else
            reset_latch <= '0';  -- Deactivate reset
            set_latch <= '1';  -- Set the latch if RD_WR is high (example condition)
           
        end if;
    end process;

end structural;
