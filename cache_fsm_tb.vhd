-- Test Bench for Cache FSM (Read Hit/Miss, Write Hit/Miss)
-- Executes four sequential transactions to verify all FSM paths.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_fsm_tb is
end cache_fsm_tb;

architecture behavioral of cache_fsm_tb is

  component cache_fsm is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        start           : in  std_logic;
        read_write      : in  std_logic;  
        cvt             : in  std_logic;  

        busy            : out std_logic;
        output_enable   : out std_logic;
        write_enable    : out std_logic;
        data_mux_sel    : out std_logic;
        decoder_enable  : out std_logic;
        memory_enable   : out std_logic;
        valid_bit		: out std_logic;
        byte_cnt_out : out std_logic_vector(1 downto 0)
    );
  end component;

  -- Signals for FSM inputs/outputs
  signal clk_s              : std_logic := '0';
  signal reset_s            : std_logic := '1';
  signal start_s            : std_logic := '0';
  signal read_write_s       : std_logic := '0';
  signal cvt_s              : std_logic := '0';
  
  signal busy_s             : std_logic;
  signal output_enable_s    : std_logic;
  signal write_enable_s     : std_logic;
  signal data_mux_sel_s     : std_logic;
  signal memory_enable_s    : std_logic;
  signal decoder_enable_s   : std_logic; 
  signal valid_bit_s		: std_logic;
  signal byte_cnt_out		: std_logic_vector(1 downto 0);
  
  -- Clock Counter Signals
  signal clk_counter_s      : integer range 0 to 200 := 0; 
  signal enable_clk_counter : std_logic := '0';
  constant CLK_PERIOD       : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: cache_fsm
    port map (
      clk             => clk_s,
      reset           => reset_s,
      start           => start_s,
      read_write      => read_write_s,
      cvt             => cvt_s,
      
      busy            => busy_s,
      output_enable   => output_enable_s,
      write_enable    => write_enable_s,
      data_mux_sel    => data_mux_sel_s,
      decoder_enable  => decoder_enable_s, 
      memory_enable   => memory_enable_s,
      valid_bit		  => valid_bit_s,
      byte_cnt_out	  => byte_cnt_out
    );

  -- Clock generation process
  clk_process: process
  begin
    loop
      clk_s <= '0';
      wait for CLK_PERIOD / 2;
      clk_s <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  counter_process: process(clk_s, reset_s, enable_clk_counter)
  begin
    if falling_edge(clk_s) and (enable_clk_counter = '1') then 
      clk_counter_s <= clk_counter_s + 1;
    end if;
  end process;


  -- Stimulus process
  stim_process: process
    -- Helper to wait for N cycles after the current P-edge 
    procedure wait_cycles(N : in integer) is
    begin
      for i in 1 to N loop
        wait until rising_edge(clk_s);
      end loop;
    end procedure;
  begin
    ----------------------------------------------------
    -- 1. Initial Reset & Setup
    
    reset_s <= '0';
    enable_clk_counter <= '1';
    wait until rising_edge(clk_s); -- Start at P1
    
  
	----------------------------------------------------
    -- TEST 1: WRITE HIT (3 Cycles: P1 -> N3)
    
    -- P1: Start request
    start_s      <= '1';
    read_write_s <= '0'; -- Write
    cvt_s        <= '1'; -- Hit
    
    wait until rising_edge(clk_s); -- P2
    start_s      <= '0'; 
    
    wait_cycles(2); 
    
	----------------------------------------------------
	----------------------------------------------------
    -- TEST 2: READ HIT (2 Cycles: P4 -> N5)
   
    -- Wait 1 stabilization cycle (P4)
    wait until rising_edge(clk_s); -- P5
    
    -- P5: Start request
    start_s      <= '1';
    read_write_s <= '1'; -- Read
    cvt_s        <= '1'; -- Hit

    wait until rising_edge(clk_s); -- P6
    start_s      <= '0';
    
    wait_cycles(1); 
    
	----------------------------------------------------
    ----------------------------------------------------
    -- TEST 3: WRITE MISS (3 Cycles: P7 -> N9)
    
    -- Wait 1 stabilization cycle (P7)
    wait until rising_edge(clk_s); -- P8
    
    -- P8: Start request
    start_s      <= '1';
    read_write_s <= '0'; -- Write
    cvt_s        <= '0'; -- Miss

    wait until rising_edge(clk_s); -- P9
    start_s      <= '0';
    
    wait_cycles(2); 
    
    ----------------------------------------------------
    ----------------------------------------------------
    -- TEST 4: READ MISS (19 Cycles: P11 -> N30)
 
    -- Wait 1 stabilization cycle (P11)
    wait until rising_edge(clk_s); -- P12
    
    -- P12: Start request
    start_s      <= '1';
    read_write_s <= '1'; -- Read
    cvt_s        <= '0'; -- Miss

    wait until rising_edge(clk_s); -- P13
    start_s      <= '0';
    
    -- Wait for the full 19-cycle latency 
    wait_cycles(18); 
    
    ----------------------------------------------------
    ----------------------------------------------------
    -- Final Stop
    wait for CLK_PERIOD * 3;
    report "Simulation Finished." severity note;
    assert false severity failure;
	 ----------------------------------------------------
  end process;

end behavioral;
