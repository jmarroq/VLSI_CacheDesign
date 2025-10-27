library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_fsm is
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
end entity;

architecture behavioral of cache_fsm is

    type state_t is (
        S_IDLE,
        S_LATCH,
        S_DECIDE,
        S_WRITE_WAIT,
        S_READ_MISS_W,
        S_READ_FETCH,
        S_READ_DONE
    );
    signal state, next_state : state_t;

    -- latched CPU inputs
    signal rw_lat, cvt_lat, start_l : std_logic := '0';

    signal cycle_cnt : integer range 0 to 64 := 0;
    signal byte_cnt : unsigned(1 downto 0) := (others => '0');

begin

	-- Map internal unsigned counter to std_logic_vector output
    byte_cnt_out <= std_logic_vector(byte_cnt);
    
    
    --------------------------------------------------------------------
    -- Sequential process, update state and latches
    --------------------------------------------------------------------
    process(clk)
    begin
        if falling_edge(clk) then
            if reset = '1' then
                state      <= S_IDLE;
                start_l    <= '0';
                rw_lat     <= '1';
                cvt_lat    <= '0';
                cycle_cnt  <= 0 ;
              
                byte_cnt   <= (others => '0');
            else
                state <= next_state;

                if next_state = S_LATCH then
                    start_l <= start;
                    rw_lat  <= read_write;
                    cvt_lat <= cvt;
                end if;

                if next_state /= S_IDLE then
                    if cycle_cnt < 64 then
                        cycle_cnt <= cycle_cnt + 1;
                    end if;
                else
                    cycle_cnt <= 0;
                end if;
                
                -- Byte counter update (used for selecting byte offset)
                if state = S_READ_FETCH then
                if (cycle_cnt = 11) or (cycle_cnt = 13) or
                   (cycle_cnt = 15) or (cycle_cnt = 17) then
                    byte_cnt <= byte_cnt + 1;
                end if;
            else
                byte_cnt <= (others => '0');
            end if;
                
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Combinational next-state and output logic 
    --------------------------------------------------------------------
    process(state, start, start_l, rw_lat, cvt_lat, cycle_cnt)
    begin
        -- defaults
        next_state    <= state;
        busy           <= '0';
        output_enable  <= '0';
        write_enable   <= '0';
        data_mux_sel   <= '0';
        decoder_enable <= '0';
        memory_enable  <= '0';
        valid_bit	   <= '0';

        case state is
            when S_IDLE =>
                if start = '1' then
                    next_state <= S_LATCH;
                end if;

            when S_LATCH =>
                busy <= '1';
                next_state <= S_DECIDE;

            when S_DECIDE =>
                if (rw_lat = '1') and (cvt_lat = '1') then       -- READ HIT
                    output_enable <= '1';
                    busy <= '0';
                    next_state <= S_IDLE;

                elsif (rw_lat = '0') and (cvt_lat = '1') then    -- WRITE HIT
                    busy <= '1';
                    write_enable <= '1';
                    data_mux_sel <= '1';
                    decoder_enable <= '1';
                    next_state <= S_WRITE_WAIT;

                elsif (rw_lat = '0') and (cvt_lat = '0') then    -- WRITE MISS
                    busy <= '1';
                    next_state <= S_WRITE_WAIT;

                elsif (rw_lat = '1') and (cvt_lat = '0') then    -- READ MISS
                    busy <= '1';
                    memory_enable <= '1';
                    next_state <= S_READ_MISS_W;
                end if;

            when S_WRITE_WAIT =>
                busy <= '0';
                next_state <= S_IDLE;

            when S_READ_MISS_W =>
                busy <= '1';
                next_state <= S_READ_FETCH;

            when S_READ_FETCH =>
                busy <= '1';
                valid_bit <= '1';
                if cycle_cnt = 11 then
                  write_enable   <= '1';
                  decoder_enable <= '1';
                  data_mux_sel   <= '1';
                  
       			elsif cycle_cnt = 13 or cycle_cnt = 15 or cycle_cnt = 17 then
                  valid_bit	<= '0'; 
                  write_enable   <= '1';
                  decoder_enable <= '1';
                  data_mux_sel   <= '1';
                  
                 elsif cycle_cnt = 18 then
        
                    next_state <= S_READ_DONE;
                end if;

            when S_READ_DONE =>
                output_enable <= '1';
                busy <= '0';
                next_state <= S_IDLE;

            when others =>
                next_state <= S_IDLE;
        end case;
    end process;

end architecture behavioral;
