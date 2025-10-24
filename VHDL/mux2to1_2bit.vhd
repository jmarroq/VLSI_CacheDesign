library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1_2bit is
  port (
    S   : in  std_logic;
    I0  : in  std_logic_vector(1 downto 0);
    I1  : in  std_logic_vector(1 downto 0);
    Y   : out std_logic_vector(1 downto 0)
  );
end mux2to1_2bit;

architecture structural of mux2to1_2bit is

  component mux2to1
    port (
      S  : in  std_logic;
      I0 : in  std_logic;
      I1 : in  std_logic;
      Y  : out std_logic
    );
  end component;

  -- Architecture binding for all generated instances
  for bitmux: mux2to1 use entity work.mux2to1(structural);

begin

  gen_mux: for i in 0 to 1 generate
    bitmux: mux2to1 port map (S, I0(i), I1(i), Y(i));
  end generate;

end structural;
