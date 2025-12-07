library IEEE;
use IEEE.std_logic_1164.all;

entity demux2to1_8bit is
    port (
        sel     : in  std_logic;
        data_in : in  std_logic_vector(7 downto 0);
        out0    : out std_logic_vector(7 downto 0);
        out1    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture structural of demux2to1_8bit is
begin
    gen_bits: for i in 0 to 7 generate
        DMX_i: entity work.demux2to1
            port map (
                sel     => sel,
                data_in => data_in(i),
                out0    => out0(i),
                out1    => out1(i)
            );
    end generate gen_bits;
end architecture;
