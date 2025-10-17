-- Entity: cache_cell
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_cell is 
    port (
        CE     : in std_logic;
        RD_WR  : in std_logic;
        D_in   : in std_logic;
        D_out  : out std_logic);
end cache_cell;

architecture structural of cache_cell is 

-- REQUIRED COMPONENTS
component cache_sel
    port (
        CE      : in  std_logic;
        RD_WR   : in  std_logic;
        RE      : out std_logic
        WE      : out std_logic);
    end component;

component Dlatch 
    port (
      D      : in  std_logic;
      EN     : in  std_logic;
      Q      : out std_logic;
      Q_n    : out std_logic);
    end component;
  
component tx
    port (
      sel   : in  std_logic;
      selnot   : in  std_logic;
      input    : in  std_logic;
      output   : out std_logic);
    end component;

component inverter
  port (
    input   : in std_logic;
    output   : out std_logic);
end component;
  
-- SIGNALS
signal RE_signal, WE_signal: std_logic;
signal RE_bar     : std_logic;
signal Q_int, Q_n_int  : std_logic;

for cache_selector1: use entity work.cache_selector(structural);
for Dlatch1: use entity work.Dlatch(structural);
for tx1: use entity work.tx(structural);
for inverter1: use entity work.inverter(structural);

begin
    cache_selector1: cache_selector port map (CE, RD_WR, RE_signal, WE_signal);
    Dlatch1: Dlatch port map (D_in, WE_signal, Q_int, Q_n_int);
    inverter1: inverter port map (RE_signal, RE_bar);
    tx1: tx port map (RE_signal, RE_bar, Q_int, D_out);

end structural;
                                        





