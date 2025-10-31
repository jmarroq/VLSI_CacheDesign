-- Positive edge-triggered DFF with reset

library ieee;
use ieee.std_logic_1164.all;

entity dff_pos is
  port(
    clk   : in  std_logic;
    d     : in  std_logic;
    reset : in  std_logic;  -- active HIGH
    q     : out std_logic
  );
end entity;

architecture structural of dff_pos is
  signal q_int : std_logic := '0';
begin
  process(clk, reset)
  begin
    if reset = '1' then
      q_int <= '0';
    elsif rising_edge(clk) then
      q_int <= d;
    end if;
  end process;
  q <= q_int;
end architecture;
