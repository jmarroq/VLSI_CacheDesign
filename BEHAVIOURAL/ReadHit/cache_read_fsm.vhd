-- FSM for Cache Read Hit Operation (Control Only)
-- This FSM generates busy, output_enable, and decoder_enable signals based on clock edges
-- and external hit_valid signal, handling all addresses/data externally.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_read_fsm is
  port (
  -- External signal (CPU and CVT)
    clk           : in  std_logic;
    reset         : in  std_logic;
    start         : in  std_logic;
    read_write    : in  std_logic;
    cvt     : in  std_logic;

    -- FSM outputs (control signals)
    busy          : out std_logic;
    output_enable : out std_logic;
    decoder_enable: out std_logic
  );
end cache_read_fsm;

architecture behavioral of cache_read_fsm is

  -- FSM states
  type state_type is (s_idle, s_busy_active, s_read_done);
  signal current_state : state_type := s_idle;

  -- Internal registers for synchronous output control
  signal busy_reg          : std_logic := '0';
  signal output_enable_reg : std_logic := '0';
  signal decoder_enable_reg: std_logic := '0';
        

begin
  -- 1. state register & transition logic (synchronous: rising edge)
  
  process(clk, reset)
  begin
    if reset = '1' then
      current_state <= s_idle;
    elsif rising_edge(clk) then
      case current_state is
        when s_idle =>
          -- CPU provides inputs
          if start = '1' and read_write = '1' then
            current_state <= s_busy_active;
          end if;

        when s_busy_active =>
          -- External logic calculates hit_valid during this cycle.
          if cvt = '1' then
            current_state <= s_read_done;
          
          end if;

        when s_read_done =>
          -- Data is stable for this entire cycle. Return to idle immediately.
          current_state <= s_idle;

      end case;
    end if;
  end process;


  -- 2. synchronous output control (synchronous: falling edge)
  -- Implements the requirement to set/clear control signals on the negative edge.
 
  process(clk)
  begin
    if falling_edge(clk) then
      -- Update output registers based on the current state (which was updated 
      -- on the previous rising edge).
      case current_state is
        
        when s_idle =>
          -- Outputs are de-asserted.
          busy_reg          <= '0';
          output_enable_reg <= '0';
          decoder_enable_reg<= '0';
        
        
        when s_busy_active =>
          --Turn on the busy signal
          busy_reg          <= '1';
          output_enable_reg <= '0';
          decoder_enable_reg<= '1';
        

        when s_read_done =>
          -- output enable should go high and the busy go low
          busy_reg          <= '0';
          output_enable_reg <= '1';
          decoder_enable_reg<= '1';
        
        
      end case;
    end if;
  end process;



  -- 3. output assignment
  busy          <= busy_reg;
  output_enable <= output_enable_reg;
  decoder_enable<= decoder_enable_reg;
        
        

end behavioral;

