library ieee;
use ieee.std_logic_1164.all;

entity input_reg is
  port (
    d_in   : in  std_logic;
    clk    : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    q_out  : out std_logic
  );
end entity;

architecture structural of input_reg is
  component and2     port (input1,input2: in std_logic; output: out std_logic); end component;
  component or2      port (input1,input2: in std_logic; output: out std_logic); end component;
  component inverter port (input: in std_logic; output: out std_logic); end component;
  component dff_pos  port (clk,d,reset: in std_logic; q: out std_logic); end component;
  component dff_neg  port (clk,d,reset: in std_logic; q: out std_logic); end component;

  signal q0      : std_logic;
  signal n_en    : std_logic;
  signal d_hold  : std_logic;
  signal d_load  : std_logic;
  signal d_next  : std_logic;

begin
  -- invert enable
  inv_en : inverter port map(enable, n_en);

  -- HOLD path (keep previous q0)
  and_hold : and2 port map(n_en, q0, d_hold);

  -- LOAD path (load new data)
  and_load : and2 port map(enable, d_in, d_load);

  -- MUX (hold vs load)
  or_next  : or2  port map(d_hold, d_load, d_next);

  -- Flip-flop (choose posedge or negedge depending on your use)
  ff0 : dff_neg port map(clk, d_next, reset, q0);

  q_out <= q0;

end architecture;
