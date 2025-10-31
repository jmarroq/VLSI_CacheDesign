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
  --------------------------------------------------------------------
  -- COMPONENTS
  --------------------------------------------------------------------
  component and2
    port ( input1, input2 : in std_logic; output : out std_logic );
  end component;

  component dff_neg
    port (
      clk   : in  std_logic;
      d     : in  std_logic;
      reset : in  std_logic;
      q     : out std_logic
    );
  end component;

  --------------------------------------------------------------------
  -- INTERNAL SIGNALS
  --------------------------------------------------------------------
  signal en_d0, en_d1, en_d2 : std_logic;  

begin
 
  -- GATE EACH INPUT BIT WITH ENABLE
  and0 : and2 port map(d_in(0), enable, en_d0);
  and1 : and2 port map(d_in(1), enable, en_d1);
  and2g: and2 port map(d_in(2), enable, en_d2);

  -- THREE DFFs (falling-edge triggered)
  dff0 : dff_neg port map(clk => clk, d => en_d0, reset => reset, q => q_out(0));
  dff1 : dff_neg port map(clk => clk, d => en_d1, reset => reset, q => q_out(1));
  dff2 : dff_neg port map(clk => clk, d => en_d2, reset => reset, q => q_out(2));

end architecture structural;
