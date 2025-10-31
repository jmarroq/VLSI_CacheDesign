library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity tb_cache_data_block is
end tb_cache_data_block;

architecture tb of tb_cache_data_block is
	-- Component declaration for the Device Under Test (DUT)
	component cache_data_block
    	port (
        	CE_index 	: in std_logic_vector(3 downto 0); -- Line select (one-hot)
        	CE_offset	: in std_logic_vector(3 downto 0); -- Byte select (one-hot)
        	RD_WR    	: in std_logic;
        	Tag_in   	: in std_logic_vector(1 downto 0);
        	Tag_out  	: out std_logic_vector(1 downto 0);
        	V_in     	: in std_logic;
        	V_out    	: out std_logic;
        	D_in     	: in std_logic_vector(7 downto 0);
        	D_out    	: out std_logic_vector(7 downto 0)
    	);
	end component;

	-- DUT signals
	signal CE_index_tb   : std_logic_vector(3 downto 0) := (others => '0');
	signal CE_offset_tb  : std_logic_vector(3 downto 0) := (others => '0');
	signal RD_WR_tb  	: std_logic := '0';
	signal Tag_in_tb 	: std_logic_vector(1 downto 0) := (others => '0');
	signal Tag_out_tb	: std_logic_vector(1 downto 0);
	signal V_in_tb   	: std_logic := '0';
	signal V_out_tb  	: std_logic;
	signal D_in_tb   	: std_logic_vector(7 downto 0) := (others => '0');
	signal D_out_tb  	: std_logic_vector(7 downto 0);

	-- Simulation constants
	constant T_DELAY : time := 20 ns;

begin
	-- Instantiate the Device Under Test (DUT)
	UUT: cache_data_block
    	port map(
        	CE_index	=> CE_index_tb,
        	CE_offset   => CE_offset_tb,
        	RD_WR   	=> RD_WR_tb,
        	Tag_in  	=> Tag_in_tb,
        	Tag_out 	=> Tag_out_tb,
        	V_in    	=> V_in_tb,
        	V_out   	=> V_out_tb,
        	D_in    	=> D_in_tb,
        	D_out   	=> D_out_tb
    	);
     	-- Clock generation process
    
	-- Stimulus process
	stim_proc: process
	begin

    	-- Initialize and hold (All disabled, Write mode)
    	CE_index_tb <= "0000"; RD_WR_tb <= '0'; D_in_tb <= X"00";
    	CE_offset_tb <= "0000"; Tag_in_tb <= "00"; V_in_tb <= '0';
    	wait for T_DELAY;
    	wait for T_DELAY;
           	 
     	-- State 1: Disabled, Write Mode, Select Line 1, Byte 0 (No effect)
    	CE_index_tb <= "0010"; RD_WR_tb <= '0'; D_in_tb <= X"FF";
    	CE_offset_tb <= "0001"; Tag_in_tb <= "01"; V_in_tb <= '0';
    	wait for T_DELAY;
   	 
    	-- State 1: Disabled, Write Mode, Select Line 1, Byte 0 (No effect)
    	CE_index_tb <= "0010"; RD_WR_tb <= '1'; D_in_tb <= X"FF";
    	CE_offset_tb <= "0001"; Tag_in_tb <= "01"; V_in_tb <= '0';
    	wait for T_DELAY;
    	wait for T_DELAY;
   	 
    	-- State 1: Disabled, Write Mode, Select Line 1, Byte 0 (No effect)
    	CE_index_tb <= "0010"; RD_WR_tb <= '0'; D_in_tb <= X"FF";
    	CE_offset_tb <= "0001"; Tag_in_tb <= "01"; V_in_tb <= '1';
    	wait for T_DELAY;
   	 
    	-- State 1: Disabled, Write Mode, Select Line 1, Byte 0 (No effect)
    	CE_index_tb <= "0010"; RD_WR_tb <= '1'; D_in_tb <= X"FF";
    	CE_offset_tb <= "0001"; Tag_in_tb <= "01"; V_in_tb <= '1';
    	wait for T_DELAY;

   	 
   	 
   	 
    	-- State 2: Write Line 1, Byte 0 (Data = X"1A", Tag = "01", Valid = '1')
    	-- CE_index on (Line 1), write enable.
    	CE_index_tb <= "0100"; RD_WR_tb <= '0'; D_in_tb <= X"1A";
    	CE_offset_tb <= "0011"; Tag_in_tb <= "10"; V_in_tb <= '1';
    	wait for T_DELAY;
   	 
           	-- State 2: Write Line 1, Byte 0 (Data = X"1A", Tag = "01", Valid = '1')
    	-- CE_index on (Line 1), write enable.
    	CE_index_tb <= "0100"; RD_WR_tb <= '1'; D_in_tb <= X"1A";
    	CE_offset_tb <= "0011"; Tag_in_tb <= "10"; V_in_tb <= '1';
    	wait for T_DELAY;
   	 
    	-- State 3: Read Line 1, Byte 0 (Expect D_out = X"1A", Tag = "01", V_out = '1')
    	-- CE_index on (Line 1), read enable.
    	CE_index_tb <= "0010"; RD_WR_tb <= '1'; D_in_tb <= X"00";
    	CE_offset_tb <= "0001"; Tag_in_tb <= "10"; V_in_tb <= '0'; -- Inputs irrelevant for read
    	wait for T_DELAY;
   	 
    	-- State 4: Write Line 3, Byte 3 (Data = X"5B", Tag = "10", Valid = '0')
    	-- CE_index on (Line 3), write enable.
    	CE_index_tb <= "1000"; RD_WR_tb <= '0'; D_in_tb <= X"5B";
    	CE_offset_tb <= "1000"; Tag_in_tb <= "10"; V_in_tb <= '0';
    	wait for T_DELAY;
   	 
    	-- State 5: Read Line 3, Byte 3 (Expect D_out = X"5B", Tag = "10", V_out = '0')
    	-- CE_index on (Line 3), read enable.
    	CE_index_tb <= "1000"; RD_WR_tb <= '1'; D_in_tb <= X"00";
    	CE_offset_tb <= "1000"; Tag_in_tb <= "00"; V_in_tb <= '0';
    	wait for T_DELAY;
   	 
    	-- State 6: Read Line 1, Byte 0 again (Verify non-destructive write to Line 3)
    	-- Expect D_out = X"1A", Tag = "01", V_out = '1'
    	CE_index_tb <= "0010"; RD_WR_tb <= '1'; D_in_tb <= X"00";
    	CE_offset_tb <= "0001"; Tag_in_tb <= "00"; V_in_tb <= '0';
    	wait for T_DELAY;

    	-- State 7: Read Line 1, Byte 2 (Verify Byte 2 holds default/previous value)
    	-- Expect D_out = default/previous value (Likely X"00" if reset was implicit or tri-state)
    	CE_index_tb <= "0010"; RD_WR_tb <= '1'; D_in_tb <= X"00";
    	CE_offset_tb <= "0100"; -- Byte 2 select
    	wait for T_DELAY;

   	 
    	wait;
	end process;
end tb;
