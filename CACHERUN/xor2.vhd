library IEEE;
use IEEE.std_logic_1164.all;

entity xor2 is
  port (
    input1 : in  std_logic;
    input2 : in  std_logic;
    output : out std_logic
  );
end xor2;

architecture structural of xor2 is

  component or2
    port (
      input1 : in  std_logic;
      input2 : in  std_logic;
      output : out std_logic
    );
  end component;

  component inverter
    port (
      input  : in  std_logic;
      output : out std_logic
    );
  end component;

  component and2
    port (
      input1 : in  std_logic;
      input2 : in  std_logic;
      output : out std_logic
    );
  end component;

  signal A_not, B_not, ABnot, AnotB : std_logic;

begin
  -- invert inputs
  inverter_1 : inverter port map(input1, A_not);
  inverter_2 : inverter port map(input2, B_not);

  -- (A and not B), (not A and B)
  and2_ABnot : and2 port map(input1, B_not, ABnot);
  and2_AnotB : and2 port map(A_not, input2, AnotB);

  -- combine results
  or2_1 : or2 port map(ABnot, AnotB, output);

end structural;
