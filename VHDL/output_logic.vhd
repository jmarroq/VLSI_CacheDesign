library ieee;
use ieee.std_logic_1164.all;

entity output_logic is
  port(
    -- Inputs
    state_in         : in  std_logic_vector(2 downto 0);
    rw_lat, cvt_lat  : in  std_logic;

    -- POS-edge flags
    c0_pos, c1_pos, c9_pos, c11_pos, c13_pos, c15_pos : in std_logic;

    -- NEG-edge flags
    c0_neg, c8_neg, c9_neg, c11_neg, c13_neg, c15_neg : in std_logic;

    -- Outputs
    busy, output_enable, rw_enable, mux_sel,
    decoder_enable, mem_enable, valid_bit, byte_enable : out std_logic
  );
end entity;

architecture structural of output_logic is
  --------------------------------------------------------------------
  -- Component declarations
  --------------------------------------------------------------------
  component and2     port(input1,input2: in std_logic; output: out std_logic); end component;
  component and3     port(input1,input2,input3: in std_logic; output: out std_logic); end component;
  component or2      port(input1,input2: in std_logic; output: out std_logic); end component;
  component inverter port(input: in std_logic; output: out std_logic); end component;

  --------------------------------------------------------------------
  -- Internal signals
  --------------------------------------------------------------------
  signal S2,S1,S0, nS2,nS1,nS0 : std_logic;
  signal I,L,D,W,RM,RF,RD : std_logic;

  signal nRW, nCVT : std_logic;
  signal read_hit, write_hit, read_miss, write_miss : std_logic;

  signal b1,b2,b3, b4,b5,  busy_int : std_logic;

  -- Helpers for multi-input ORs
  signal or_pos_a, or_pos_b, or_pos_all : std_logic;
  signal or_byte_a, or_byte_b, or_byte_all : std_logic;
  signal or_mux_pos : std_logic;
  signal or_val_early : std_logic;

  -- RW_ENABLE helper terms
  signal rf_and_pos, d_and_c0n, rw_or, rw_inv : std_logic;

  -- Output-enable helper
  signal d_and_readhit, oe_or : std_logic;

  -- MUX helper
  signal d_wh_mux, mux_or : std_logic;

  -- MEM enable helper
  signal d_and_rmiss : std_logic;
  signal d_and_wh : std_logic;
  
  -- DEC enable helper
  signal d_busy: std_logic;
  signal mux_readhit: std_logic;

begin
  --------------------------------------------------------------------
  -- State decode (3-7 one-hot)
  --------------------------------------------------------------------
  S2 <= state_in(2); 
  S1 <= state_in(1);
  S0 <= state_in(0);
  
  invS2: inverter port map(S2, nS2);
  invS1: inverter port map(S1, nS1);
  invS0: inverter port map(S0, nS0);

  and_I  : and3 port map(nS2, nS1, nS0, I);     -- 000
  and_L  : and3 port map(nS2, nS1,  S0, L);     -- 001
  and_D  : and3 port map(nS2,  S1, nS0, D);     -- 010
  and_W  : and3 port map(nS2,  S1,  S0, W);     -- 011
  and_RM : and3 port map( S2, nS1, nS0, RM);    -- 100
  and_RF : and3 port map( S2, nS1,  S0, RF);    -- 101
  and_RD : and3 port map( S2,  S1, nS0, RD);    -- 110 

  --------------------------------------------------------------------
  -- Hit/Miss decode
  --------------------------------------------------------------------
  inv_rw : inverter port map(rw_lat,  nRW);
  inv_cv : inverter port map(cvt_lat, nCVT);

  and_read_hit  : and2 port map(rw_lat, cvt_lat, read_hit);
  and_write_hit : and2 port map(nRW,    cvt_lat, write_hit);
  and_read_miss : and2 port map(rw_lat, nCVT,    read_miss);
  and_write_miss: and2 port map(nRW, 	nCVT, write_miss); --

  --------------------------------------------------------------------
  -- busy = L + (D & (read_miss + write_hit)) + RM + RF
  --------------------------------------------------------------------
   or_busy_a : or2 port map(read_miss, write_hit, b1);
  or_busy_b : or2 port map(b1, write_miss, b2);
  and_busy_d: and2 port map(D, b2, b3);
  or_busy_c : or2 port map(L, b3, b4);
  or_busy_d : or2 port map(b4, RM, b5);
  or_busy_e : or2 port map(b5, RF, busy);

  --------------------------------------------------------------------
  -- output_enable = (D & read_hit) + RD
  --------------------------------------------------------------------
  and_oe0 : and2 port map(D, read_hit, d_and_readhit);
  or_oe   : or2  port map(d_and_readhit, RD, output_enable);

  --------------------------------------------------------------------
  -- mem_enable = D & read_miss
  --------------------------------------------------------------------
  and_mem : and2 port map(D, read_miss, mem_enable);

  --------------------------------------------------------------------
  -- rw_enable = NOT [ (RF & (c9_pos + c11_pos + c13_pos + c15_pos)) + (D & c0_neg & writehit) ]
  --------------------------------------------------------------------
  or_pos1   : or2  port map(c9_pos, c11_pos, or_pos_a);
  or_pos2   : or2  port map(c13_pos, c15_pos, or_pos_b);
  or_pos3   : or2  port map(or_pos_a, or_pos_b, or_pos_all);
  and_rfpos : and2 port map(RF, or_pos_all, rf_and_pos);

  and_d_c0n : and3 port map(D, c0_neg, write_hit, d_and_c0n);

  or_rw     : or2  port map(rf_and_pos, d_and_c0n, rw_or);
  inv_rwE   : inverter port map(rw_or, rw_enable);
 

  --------------------------------------------------------------------
  -- valid_bit = RF & (c8_neg + c9_neg)
  --------------------------------------------------------------------
--   or_val0 : or2  port map(c8_neg, c9_neg, or_val_early);
--   and_val : and2 port map(RF, or_val_early, valid_bit);
  valid_bit <= '1';

  --------------------------------------------------------------------
  -- BYTE_ENABLE = RF & (c9_neg | c11_neg | c13_neg | c15_neg)
  --------------------------------------------------------------------
  or_be1 : or2  port map(c9_neg,  c11_neg, or_byte_a);
  or_be2 : or2  port map(c13_neg, c15_neg, or_byte_b);
  or_be3 : or2  port map(or_byte_a, or_byte_b, or_byte_all);
  and_be : and2 port map(RF, or_byte_all, byte_enable);

  --------------------------------------------------------------------
  -- DECODER_ENABLE = BUSY OR READ DONE
  --------------------------------------------------------------------
  decoder_enable <= '1';

   --------------------------------------------------------------------
  -- MUX_SEL = (D & write_hit & (c0_pos + c1_pos)) + RD
  --------------------------------------------------------------------
  or_muxp : or2  port map(c0_pos, c1_pos, or_mux_pos);

  -- (D & write_hit & (c0_pos + c1_pos))
  --and_d_wh  : and2 port map(D, write_hit, d_and_wh);
  and_mux0  : and2 port map(write_hit, or_mux_pos, d_wh_mux);
  or_hit1: or2 port map(d_wh_mux, read_hit, mux_readhit);

  -- Final OR with RD
  or_mux0   : or2  port map(mux_readhit, RD, mux_sel);
  

end architecture structural;
