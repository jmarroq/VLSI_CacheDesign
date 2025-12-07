library IEEE;
use IEEE.std_logic_1164.all;

entity demux2to1 is
    port (
        sel     : in  std_logic;   -- select line
        data_in : in  std_logic;   -- input data
        out0    : out std_logic;   -- output 0
        out1    : out std_logic    -- output 1
    );
end entity;

architecture structural of demux2to1 is
    signal sel_not : std_logic;
begin
    -- Invert select
    sel_inv: entity work.inverter
        port map (
            input  => sel,
            output => sel_not
        );

    -- Gate data_in to out0 using and2
    and0: entity work.and2
        port map (
            input1 => data_in,
            input2 => sel_not,
            output => out0
        );

    -- Gate data_in to out1 using and2
    and1: entity work.and2
        port map (
            input1 => data_in,
            input2 => sel,
            output => out1
        );
end architecture;
