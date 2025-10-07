-- Entity: mux2to1_8bit
-- Architecture: structural
-- Author: Juan Marroquin

library STD;
library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1_8bit is
  port (
    S   : in  std_logic;                     
    I0  : in  std_logic_vector(7 downto 0);  
    I1  : in  std_logic_vector(7 downto 0); 
    Y   : out std_logic_vector(7 downto 0)  
  );
end mux2to1_8bit;

architecture structural of mux2to1_8bit is

  component mux2to1
    port (
      S  : in  std_logic;
      I0 : in  std_logic;
      I1 : in  std_logic;
      Y  : out std_logic
    );
  end component;

begin

  -- Explicit architecture binding for each instance (layout-friendly)
  for mux0: mux2to1 use entity work.mux2to1(structural);
  for mux1: mux2to1 use entity work.mux2to1(structural);
  for mux2: mux2to1 use entity work.mux2to1(structural);
  for mux3: mux2to1 use entity work.mux2to1(structural);
  for mux4: mux2to1 use entity work.mux2to1(structural);
  for mux5: mux2to1 use entity work.mux2to1(structural);
  for mux6: mux2to1 use entity work.mux2to1(structural);
  for mux7: mux2to1 use entity work.mux2to1(structural);

  -- Instantiate 8 mux2to1s, one per bit
  mux0: mux2to1 port map (S, I0(0), I1(0), Y(0));
  mux1: mux2to1 port map (S, I0(1), I1(1), Y(1));
  mux2: mux2to1 port map (S, I0(2), I1(2), Y(2));
  mux3: mux2to1 port map (S, I0(3), I1(3), Y(3));
  mux4: mux2to1 port map (S, I0(4), I1(4), Y(4));
  mux5: mux2to1 port map (S, I0(5), I1(5), Y(5));
  mux6: mux2to1 port map (S, I0(6), I1(6), Y(6));
  mux7: mux2to1 port map (S, I0(7), I1(7), Y(7));

end structural;
