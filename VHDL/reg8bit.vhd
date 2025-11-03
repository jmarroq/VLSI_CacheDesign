-- Entity: reg8
-- Architecture: structural (Hold/Load gated)
-- Author: Juan Marroquin


library IEEE;
use IEEE.std_logic_1164.all;

entity reg8 is
  port (
    D      : in  std_logic_vector(7 downto 0);  -- Data input
    CLK    : in  std_logic;
    RESET  : in  std_logic;
    ENABLE : in  std_logic;                     -- Load enable
    Q      : out std_logic_vector(7 downto 0)   -- Data output
  );
end entity;

architecture structural of reg8 is
  ----------------------------------------------------------------
  -- Component declarations
  ----------------------------------------------------------------
  component and2
    port ( input1, input2 : in std_logic; output : out std_logic );
  end component;

  component or2
    port ( input1, input2 : in std_logic; output : out std_logic );
  end component;

  component inverter
    port ( input : in std_logic; output : out std_logic );
  end component;

  component dff_neg
    port ( clk, d, reset : in std_logic; q : out std_logic );
  end component;

  ----------------------------------------------------------------
  -- Internal signals
  ----------------------------------------------------------------
  signal n_en          : std_logic;
  signal q_int         : std_logic_vector(7 downto 0);
  signal d_hold        : std_logic_vector(7 downto 0);
  signal d_load        : std_logic_vector(7 downto 0);
  signal d_next        : std_logic_vector(7 downto 0);

begin
  ----------------------------------------------------------------
  -- Invert enable
  ----------------------------------------------------------------
  inv_en : inverter port map ( input => ENABLE, output => n_en );

  ----------------------------------------------------------------
  -- Generate 8 bits of gated DFFs
  ----------------------------------------------------------------
  gen_reg : for i in 0 to 7 generate

    and_hold_i : and2
      port map (
        input1 => n_en,
        input2 => q_int(i),
        output => d_hold(i)
      );

    and_load_i : and2
      port map (
        input1 => ENABLE,
        input2 => D(i),
        output => d_load(i)
      );

    or_next_i : or2
      port map (
        input1 => d_hold(i),
        input2 => d_load(i),
        output => d_next(i)
      );

    ff_i : dff_neg
      port map (
        clk   => CLK,
        d     => d_next(i),
        reset => RESET,
        q     => q_int(i)
      );

  end generate;

  ----------------------------------------------------------------
  -- Output assignment
  ----------------------------------------------------------------
  Q <= q_int;

end architecture;
