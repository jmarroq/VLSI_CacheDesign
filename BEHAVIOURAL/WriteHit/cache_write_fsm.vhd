-- FSM for Cache Write Hit Operation (Control Only)
-- Total operation latency (start to busy drop) is 3 clock cycles.
-- write_enable is active-low (WE='0' means WRITE).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_write_fsm is
  port (
    -- External signal (CPU and CVT)
    clk           : in  std_logic;
    reset         : in  std_logic;
    start         : in  std_logic;
    read_write    : in  std_logic; 
    cvt           : in  std_logic; 
    
    -- FSM outputs (control signals)
    busy          : out std_logic;
    write_enable  : out std_logic;  -- ACTIVE-LOW: '0' enables write to cache cell
    data_mux_sel  : out std_logic;  
    decoder_enable: out std_logic   -- ACTIVE-HIGH: '1' enables the byte select 
  );
end cache_write_fsm;

architecture behavioral of cache_write_fsm is

  -- FSM states
  type state_type is (s_idle, s_busy_tag_check, s_write_data, s_write_done);
  signal current_state : state_type := s_idle;

  -- Internal registers for synchronous output control (driven by falling edge)
  signal busy_reg          : std_logic := '0';
  signal write_enable_reg  : std_logic := '1'; 
  signal data_mux_sel_reg  : std_logic := '0';
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
          -- CPU provides write request (start='1', read_write='0')
          if start = '1' and read_write = '0' then
            current_state <= s_busy_tag_check;
          end if;

        when s_busy_tag_check =>
          -- CVT logic confirms hit.
          if cvt = '1' then
            current_state <= s_write_data;
          end if;

        when s_write_data =>
          -- Write occurs on the negative edge of this cycle. Transition to completion signaling.
          current_state <= s_write_done;

        when s_write_done =>
          -- Busy signal drops on the negative edge of this cycle. Return to idle.
          current_state <= s_idle;

      end case;
    end if;
  end process;

  
  -- 2. synchronous output control (synchronous: falling edge)

  process(clk)
  begin
    if falling_edge(clk) then
      
      case current_state is
        
        when s_idle =>
          busy_reg          <= '0';
          write_enable_reg  <= '1'; -- Inactive (High)
          data_mux_sel_reg  <= '0';
          decoder_enable_reg<= '0';
        
        when s_busy_tag_check =>
          -- Negative Edge 1: Inputs latched externally, busy turned on.
          busy_reg          <= '1';
          write_enable_reg  <= '1'; -- Write is disabled
          data_mux_sel_reg  <= '1'; -- Select CPU data to be ready at MUX output
          decoder_enable_reg<= '0';
        
        when s_write_data =>
          -- Negative Edge 2: Data is written to cache. Busy stays high.
          busy_reg          <= '1';
          write_enable_reg  <= '0'; -- ENABLE WRITE (Active Low)
          data_mux_sel_reg  <= '1'; 
          decoder_enable_reg<= '1'; -- ENABLE DECODER (Active High)
        
        when s_write_done =>
          -- Negative Edge 3: Busy goes low, signaling end of operation.
          busy_reg          <= '0';
          write_enable_reg  <= '1'; -- Inactive (High)
          data_mux_sel_reg  <= '0';
          decoder_enable_reg<= '0';
          
      end case;
    end if;
  end process;


  -- 3. output assignment
  
  busy           <= busy_reg;
  write_enable   <= write_enable_reg;
  data_mux_sel   <= data_mux_sel_reg;
  decoder_enable <= decoder_enable_reg;

end behavioral;
