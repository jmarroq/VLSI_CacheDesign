library ieee;
use ieee.std_logic_1164.all;

entity input_reg is
  port (
    d_in   : in  std_logic_vector(2 downto 0);  -- {start, rw, cvt}
    clk    : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    q_out  : out std_logic_vector(2 downto 0)   -- {start_l, rw_lat, cvt_lat}
  );
end entity;

architecture structural of input_reg is
  component and2     port (input1,input2: in std_logic; output: out std_logic); end component;
  component or2      port (input1,input2: in std_logic; output: out std_logic); end component;
  component inverter port (input: in std_logic; output: out std_logic); end component;
  component dff_neg  port (clk,d,reset: in std_logic; q: out std_logic); end component;

  signal q0,q1,q2      : std_logic; 
  signal n_en          : std_logic;  
  signal d0_hold,d1_hold,d2_hold : std_logic;  
  signal d0_load,d1_load,d2_load : std_logic; 
  signal d0_next,d1_next,d2_next : std_logic;  
begin
  -- invert enable
  inv_en : inverter port map(enable, n_en);

  -- bit 0 (cvt)
  and0_hold : and2 port map(n_en, q0, d0_hold);
  and0_load : and2 port map(enable, d_in(0), d0_load);
  or0_next  : or2  port map(d0_hold, d0_load, d0_next);
  ff0       : dff_neg port map(clk, d0_next, reset, q0);

  -- bit 1 (rw)
  and1_hold : and2 port map(n_en, q1, d1_hold);
  and1_load : and2 port map(enable, d_in(1), d1_load);
  or1_next  : or2  port map(d1_hold, d1_load, d1_next);
  ff1       : dff_neg port map(clk, d1_next, reset, q1);

  -- bit 2 (start)
  and2_hold : and2 port map(n_en, q2, d2_hold);
  and2_load : and2 port map(enable, d_in(2), d2_load);
  or2_next  : or2  port map(d2_hold, d2_load, d2_next);
  ff2       : dff_neg port map(clk, d2_next, reset, q2);

  q_out <= q2 & q1 & q0;  -- {start_l, rw_lat, cvt_lat}
end architecture;
