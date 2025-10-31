
-- Entity: tx_8bit
-- Architecture: structural
-- Author: Juan Marroquin


library IEEE;
use IEEE.std_logic_1164.all;

entity tx_8bit is
  port (
    sel    : in  std_logic;
    selnot : in  std_logic;
    input  : in  std_logic_vector(7 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
end tx_8bit;

architecture structural of tx_8bit is
begin
  tx_process : process(sel, selnot, input)
  begin
    if (sel = '1' and selnot = '0') then
      output <= input;
    else
      output <= (others => 'Z');
    end if;
  end process tx_process;
end structural;
