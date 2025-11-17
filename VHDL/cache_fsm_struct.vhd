library ieee;
use ieee.std_logic_1164.all;

entity cache_fsm_struct is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;     
        start           : in  std_logic;
        read_write      : in  std_logic;    
        cvt             : in  std_logic;    
        busy            : out std_logic;
        output_enable   : out std_logic;
        rw_enable       : out std_logic;
        mux_sel         : out std_logic;
        decoder_enable  : out std_logic;
        mem_enable      : out std_logic;
        valid_bit       : out std_logic;
        byte_cnt_out    : out std_logic_vector(1 downto 0);
        latch_en	: out std_logic
    );
end entity;

architecture structural of cache_fsm_struct is

    --------------------------------------------------------------------
    -- Component declarations
    --------------------------------------------------------------------
    component dff_neg
      port(
        clk   : in  std_logic;
        d     : in  std_logic;
        reset : in  std_logic;  
        q     : out std_logic
      );
    end component;

    component and2 port ( input1, input2 : in std_logic; output : out std_logic ); end component;
    component or2 port ( input1, input2 : in std_logic; output : out std_logic ); end component;
    component and3 port ( input1, input2, input3 : in std_logic; output : out std_logic ); end component;
    component inverter port ( input : in std_logic; output : out std_logic ); end component;
    
    component next_state_logic
      port (
        state_in   : in  std_logic_vector(2 downto 0);
        start      : in  std_logic;
        rw_lat     : in  std_logic;
        cvt_lat    : in  std_logic;
        c16_neg    : in  std_logic;
        next_state : out std_logic_vector(2 downto 0)
      );
    end component;

    component output_logic
      port (
        state_in        : in  std_logic_vector(2 downto 0);
        rw_lat, cvt_lat : in  std_logic;
        c0_pos, c1_pos, c9_pos, c11_pos, c13_pos, c15_pos : in std_logic;
        c0_neg, c8_neg, c9_neg, c11_neg, c13_neg, c15_neg: in std_logic;
        busy, output_enable, rw_enable, mux_sel,
        decoder_enable, mem_enable, valid_bit, byte_enable : out std_logic
      );
    end component;

    component cycle_timer
      port (
        clk, reset, busy : in std_logic;
        c0_pos, c1_pos, c9_pos, c11_pos, c13_pos, c15_pos : out std_logic;
        c0_neg, c8_neg, c9_neg, c11_neg, c13_neg, c15_neg, c16_neg : out std_logic
      );
    end component;

    component byte_counter
      port (
        clk, reset, enable : in std_logic;
        byte_cnt_out : out std_logic_vector(1 downto 0)
      );
    end component;

    component input_reg
      port (
        d_in   : in  std_logic;
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        q_out  : out std_logic  
      );
    end component;
    component input_reg2
      port (
        d_in   : in  std_logic;
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        q_out  : out std_logic  
      );
    end component;


    --------------------------------------------------------------------
    -- Internal signals
    --------------------------------------------------------------------
    signal state, next_state : std_logic_vector(2 downto 0);
    signal rw_lat, cvt_lat : std_logic;

    -- Cycle timer flags
    signal c0_pos, c1_pos, c9_pos, c11_pos, c13_pos, c15_pos : std_logic;
    signal c0_neg, c8_neg, c9_neg, c11_neg, c13_neg, c15_neg, c16_neg : std_logic;

    -- Internal enables
    signal byte_enable : std_logic;
    signal latch_en_internal, nS2, nS1, nS0, latch_tmp : std_logic;
 
    signal busy_internal : std_logic;
    
    signal notS1, notS2 : std_logic;
    signal latch_en_internal2, latch_tmp2, latch_en2  : std_logic;

begin
--     --------------------------------------------------------------------
--     -- STATE REGISTER (3 Negedge FFs with active-high reset)
--     --------------------------------------------------------------------
    dff0: dff_neg port map(clk => clk, d => next_state(0), reset => reset, q => state(0));
    dff1: dff_neg port map(clk => clk, d => next_state(1), reset => reset, q => state(1));
    dff2: dff_neg port map(clk => clk, d => next_state(2), reset => reset, q => state(2));

--     --------------------------------------------------------------------
--     -- DECODE latch_en WHEN state = 001 (S_LATCH)
--     --------------------------------------------------------------------
     invS2: inverter port map(next_state(2), nS2);
     invS1: inverter port map(next_state(1), nS1);

     and_l0: and2 port map(nS2, nS1, latch_tmp);
     and_l1: and2 port map(latch_tmp, next_state(0), latch_en_internal);
     latch_en <= latch_en_internal;


     invS21: inverter port map(state(2), notS2);
     invS11: inverter port map(state(1), notS1);

     and_l01: and2 port map(notS2, notS1, latch_tmp2);
     and_l11: and2 port map(latch_tmp2, state(0), latch_en_internal2);
     latch_en2 <= latch_en_internal2;
  
    --------------------------------------------------------------------
    -- INPUT REGISTER 
    --------------------------------------------------------------------
    busy     <= busy_internal;

    -- RW latch
    RW_Reg : input_reg
      port map(
        d_in   => read_write,
        clk    => clk,
        reset  => reset,
        enable => latch_en_internal,
        q_out  => rw_lat
      );

    -- CVT latch
    CVT_Reg : input_reg2
      port map(
        d_in   => cvt,
        clk    => clk,
        reset  => reset,
        enable => latch_en_internal2,
        q_out  => cvt_lat
      );



    --------------------------------------------------------------------
    -- NEXT-STATE LOGIC
    --------------------------------------------------------------------
    NextStateLogic: next_state_logic
      port map(
        state_in   => state,
        start      => start,
        rw_lat     => rw_lat,
        cvt_lat    => cvt_lat,
        c16_neg    => c16_neg,
        next_state => next_state
      );

    --------------------------------------------------------------------
    -- OUTPUT LOGIC
    --------------------------------------------------------------------
    OutputLogic: output_logic
      port map(
        state_in       => state, 
        rw_lat         => rw_lat, 
        cvt_lat        => cvt_lat, --

        -- POS flags
        c0_pos         => c0_pos,
        c1_pos         => c1_pos,
        c9_pos         => c9_pos,
        c11_pos        => c11_pos,
        c13_pos        => c13_pos,
        c15_pos        => c15_pos,

        -- NEG flags
        c0_neg         => c0_neg,
        c8_neg         => c8_neg,
        c9_neg         => c9_neg,
        c11_neg        => c11_neg,
        c13_neg        => c13_neg,
        c15_neg        => c15_neg,
       

        -- Outputs
        busy           => busy_internal,
        output_enable  => output_enable,
        rw_enable      => rw_enable,
        mux_sel        => mux_sel,
        decoder_enable => decoder_enable,
        mem_enable     => mem_enable,
        valid_bit      => valid_bit,
        byte_enable    => byte_enable
      );

    --------------------------------------------------------------------
    -- CYCLE TIMER (enabled when busy = 1)
    --------------------------------------------------------------------
    CycleTimer: cycle_timer
      port map(
        clk      => clk,
        reset    => reset,
        busy     => busy_internal,

        -- POS flags
        c0_pos   => c0_pos,
        c1_pos   => c1_pos,
        c9_pos   => c9_pos,
        c11_pos  => c11_pos,
        c13_pos  => c13_pos,
        c15_pos  => c15_pos,

        -- NEG flags
        c0_neg   => c0_neg,
        c8_neg   => c8_neg,
        c9_neg   => c9_neg,
        c11_neg  => c11_neg,
        c13_neg  => c13_neg,
        c15_neg  => c15_neg,
        c16_neg  => c16_neg
      );

    --------------------------------------------------------------------
    -- BYTE COUNTER (pulsed by byte enabled when writing on readmiss)
    --------------------------------------------------------------------
    ByteCounter: byte_counter
      port map(
        clk          => clk,
        reset        => reset,
        enable       => byte_enable,
        byte_cnt_out => byte_cnt_out
      );

end architecture structural;
