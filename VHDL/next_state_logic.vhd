library ieee;
use ieee.std_logic_1164.all;

entity next_state_logic is
  port(
    state_in   : in  std_logic_vector(2 downto 0);  
    start      : in  std_logic;
    rw_lat     : in  std_logic;
    cvt_lat    : in  std_logic;
    c16_neg    : in  std_logic;
    next_state : out std_logic_vector(2 downto 0)
  );
end next_state_logic;

architecture structural of next_state_logic is
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
  signal S2, S1, S0 : std_logic;
  signal notS2, notS1, notS0 : std_logic;
  signal nstart, nrw, ncvt, nc16 : std_logic;

  -- One-hot decode
  signal I, L, D, W, RM, RF, RD : std_logic;

  -- Derived terms
  signal rw_and_ncvt : std_logic;
  signal RF_hold : std_logic;

  -- Next-state one-hots
  signal L_next, D_next, W_next, RM_next, RF_next, RD_next : std_logic;

  -- Encoded bits
  signal ns0_a, ns1_a, ns2_a : std_logic;
  signal NS0, NS1, NS2 : std_logic;

begin
  --------------------------------------------------------------------
  -- Assign bits
  --------------------------------------------------------------------
  S2 <= state_in(2);
  S1 <= state_in(1);
  S0 <= state_in(0);

  --------------------------------------------------------------------
  -- Inverters
  --------------------------------------------------------------------
  invS2 : inverter port map(S2, notS2);
  invS1 : inverter port map(S1, notS1);
  invS0 : inverter port map(S0, notS0);
  inv_st: inverter port map(start, );
  inv_rw: inverter port map(rw_lat, nrw);
  inv_cv: inverter port map(cvt_lat, ncvt);
  inv_c : inverter port map(c16_neg, nc16);
RD
  --------------------------------------------------------------------
  -- One-hot decode (3-bit -> 7 lines)
  --------------------------------------------------------------------
  and_I  : and3 port map(notS2, notS1, notS0, I);   -- 000
  and_L  : and3 port map(notS2, notS1,  S0, L);     -- 001
  and_D  : and3 port map(notS2,  S1, notS0, D);     -- 010
  and_RM : and3 port map( S2, notS1, notS0, RM);    -- 100
  and_RF : and3 port map( S2, notS1,  S0, RF);      -- 101


  --------------------------------------------------------------------
  -- Common terms
  --------------------------------------------------------------------
  -- rw & ~cvt
  and_ncv : and2 port map(rw_lat, ncvt, rw_and_ncvt);

  --------------------------------------------------------------------
  -- Next-state generation
  --------------------------------------------------------------------
  -- Idle is implicit: when none of L_next/D_next/W_next/RM_next/RF_next/RD_next assert,
  
  -- L_next = I & start
  and_Ln : and2 port map(I, start, L_next);

  -- D_next = L
  D_next <= L;

  -- W_next = D & ~rw
  and_Wn : and2 port map(D, nrw, W_next);c

  -- RM_next = D & (rw & ~cvt)
  and_RMn : and2 port map(D, rw_and_ncvt, RM_next);

  -- RF_next = RM OR (RF & ~c16_neg)
  and_RFhold : and2 port map(RF, nc16, RF_hold);c
  or_RFn     : or2  port map(RM, RF_hold, RF_next);

  -- RD_next = RF & c16_neg
  and_RDn : and2 port map(RF, c16_neg, RD_next);

  --------------------------------------------------------------------
  -- Encode 3-bit next_state
  --------------------------------------------------------------------
  -- NS0 = L_next OR W_next OR RF_next
  or_ns0a : or2 port map(L_next, W_next, ns0_a);
  or_ns0  : or2 port map(ns0_a, RF_next, NS0);

  -- NS1 = D_next OR W_next OR RD_next
  or_ns1a : or2 port map(D_next, W_next, ns1_a);
  or_ns1  : or2 port map(ns1_a, RD_next, NS1);

  -- NS2 = RM_next OR RF_next OR RD_next
  or_ns2a : or2 port map(RM_next, RF_next, ns2_a);
  or_ns2  : or2 port map(ns2_a, RD_next, NS2);

  --------------------------------------------------------------------
  -- Output
  --------------------------------------------------------------------
  next_state <= NS2 & NS1 & NS0;

end  structural;
