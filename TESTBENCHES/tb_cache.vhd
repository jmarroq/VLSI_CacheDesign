
-- Testbench: tb_cache
-- Author: Juan Marroquin


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_cache is
end entity;

architecture tb of tb_cache is

  --------------------------------------------------------------------
  -- DUT Declaration
  --------------------------------------------------------------------
  component cache
    port (
      CPU_Data        : inout std_logic_vector(7 downto 0);
      CPU_Address     : in    std_logic_vector(7 downto 0);
      Memory_Data     : inout std_logic_vector(7 downto 0);
      Memory_Address  : out   std_logic_vector(7 downto 0);
      read_write      : in    std_logic;
      start           : in    std_logic;
      reset           : in    std_logic;
      clk             : in    std_logic;
      busy            : out   std_logic;
      mem_enable      : out   std_logic
    );
  end component;

  --------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------
  signal CPU_Data_tb       : std_logic_vector(7 downto 0) := (others => 'Z'); -- inout bus
  signal CPU_Address_tb    : std_logic_vector(7 downto 0) := (others => '0');
  signal Memory_Data_tb    : std_logic_vector(7 downto 0) := (others => 'Z'); -- inout bus
  signal Memory_Address_tb : std_logic_vector(7 downto 0);
  signal read_write_tb     : std_logic := '0';
  signal start_tb          : std_logic := '0';
  signal reset_tb          : std_logic := '0';
  signal clk_tb            : std_logic := '0';
  signal busy_tb           : std_logic;
  signal mem_enable_tb     : std_logic;

  constant CLK_PERIOD : time := 10 ns;

begin

  --------------------------------------------------------------------
  -- DUT Instantiation
  --------------------------------------------------------------------
  UUT: cache
    port map (
      CPU_Data       => CPU_Data_tb,
      CPU_Address    => CPU_Address_tb,
      Memory_Data    => Memory_Data_tb,
      Memory_Address => Memory_Address_tb,
      read_write     => read_write_tb,
      start          => start_tb,
      reset          => reset_tb,
      clk            => clk_tb,
      busy           => busy_tb,
      mem_enable     => mem_enable_tb
    );

  --------------------------------------------------------------------
  -- Clock Generation (10 ns period)
  --------------------------------------------------------------------
  clk_process : process
  begin
    while true loop
      clk_tb <= '0';
      wait for CLK_PERIOD / 2;
      clk_tb <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  --------------------------------------------------------------------
  -- Stimulus Process
  --------------------------------------------------------------------
  stim_proc : process
    procedure wait_cycles(N : in integer) is
    begin
      for i in 1 to N loop
        wait until rising_edge(clk_tb);
      end loop;
    end procedure;
  begin
    ----------------------------------------------------------------
    -- RESET
    ----------------------------------------------------------------
    report "=== RESETTING CACHE ===" severity note;
    reset_tb <= '1';
    wait_cycles(3);
    reset_tb <= '0';
    report "=== RELEASED RESET ===" severity note;

    wait_cycles(2);
    
    --     ----------------------------------------------------------------
--     -- TEST 5: READ LINE 3 (New address - should be miss)
--     ----------------------------------------------------------------
      report "=== TEST 5: READ MISS (New Line) ===" severity note;
      CPU_Address_tb <= "11010000";  -- Different tag/index
      CPU_Data_tb    <= (others => 'Z');
      Memory_Data_tb <= X"3C";       -- Memory supplies data
      read_write_tb  <= '1';
      start_tb       <= '1';
      wait_cycles(1);
      start_tb <= '0';
      wait_cycles(20);


-- --     ----------------------------------------------------------------
-- --     -- TEST 3: READ HIT (Cache hit - no memory access)
-- --     ----------------------------------------------------------------
      report "=== TEST 3: READ HIT ===" severity note;
      CPU_Address_tb <= "10010000";
      CPU_Data_tb    <= (others => 'Z'); -- CPU expecting data
      read_write_tb  <= '1';
      start_tb       <= '1';
      wait_cycles(1);
      start_tb <= '0';
      wait_cycles(5);

--     ----------------------------------------------------------------
--     -- TEST 4: WRITE MISS
--     ----------------------------------------------------------------
      report "=== TEST 4: WRITE HIT ===" severity note;
      CPU_Address_tb <= "10001000";
      CPU_Data_tb    <= X"5B";  -- CPU drives new data
      read_write_tb  <= '0';
      start_tb       <= '1';
      wait_cycles(1);
      start_tb <= '0';
      wait_cycles(5);
      
      --     ----------------------------------------------------------------
--     -- TEST 4: WRITE HIT (Modify cached data)
--     ----------------------------------------------------------------
      report "=== TEST 4: WRITE HIT ===" severity note;
      CPU_Address_tb <= "11011000";
      CPU_Data_tb    <= X"5B";  -- CPU drives new data
      read_write_tb  <= '0';
      start_tb       <= '1';
      wait_cycles(1);
      start_tb <= '0';
      wait_cycles(5);



    ----------------------------------------------------------------
    -- END SIMULATION
    ----------------------------------------------------------------
    report "=== ALL TESTS COMPLETE ===" severity note;
    wait for 100 ns;
    assert false report "End of simulation" severity failure;
  end process;


end architecture;
