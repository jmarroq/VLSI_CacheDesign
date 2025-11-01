library IEEE;
use IEEE.std_logic_1164.all;

entity Dlatch is
  port ( 
    D   : in  std_logic;
    EN  : in  std_logic;
    Q   : out std_logic;
    Q_n : out std_logic
  );
end Dlatch;

architecture behavioral of Dlatch is 
begin
  output: process (D, EN) -- Sensitivity list includes D and EN to infer a latch
  begin
    -- Positive level-sensitive D-Latch
    if EN = '1' then
      Q <= D;
      Q_n <= not D;
    end if; 
   
  end process output;
end behavioral;
