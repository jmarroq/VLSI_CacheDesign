-- Entity: decoder2to4
-- Architecture: structural
-- Author: Juan Marroquin


library IEEE;
use IEEE.std_logic_1164.all;

entity decoder2to4 is 
  port (
    EN : in  std_logic;
    A  : in  std_logic_vector(1 downto 0);
    Y  : out std_logic_vector(3 downto 0)
  );
end decoder2to4;

architecture structural of decoder2to4 is

  -- Components
  component and3 is
    port (
      input1 : in  std_logic;
      input2 : in  std_logic;
      input3 : in  std_logic;
      output : out std_logic
    );
  end component;

  component inverter is
    port (
      input  : in  std_logic;
      output : out std_logic
    );
  end component;

  -- Internal signals
  signal Anot_0, Anot_1 : std_logic;

begin
  -- Inverters
  inv1 : inverter port map (input => A(0), output => Anot_0);
  inv2 : inverter port map (input => A(1), output => Anot_1);

  -- AND3 logic for 4 decoded outputs
  and3_0 : and3 port map (input1 => EN, input2 => Anot_1, input3 => Anot_0, output => Y(3));
  and3_1 : and3 port map (input1 => EN, input2 => Anot_1, input3 => A(0),   output => Y(2));
  and3_2 : and3 port map (input1 => EN, input2 => A(1),   input3 => Anot_0, output => Y(1));
  and3_3 : and3 port map (input1 => EN, input2 => A(1),   input3 => A(0),   output => Y(0));

end structural;
