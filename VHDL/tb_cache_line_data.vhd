-- Entity: tb_cache_line_data
-- Author: Hannah Mathew
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity tb_cache_line_data is
end tb_cache_line_data;

architecture tb of tb_cache_line_data is
	-- Component declaration for the Device Under Test (DUT)
	component cache_line_data
    	port (
        	CE_index 	: in std_logic;
        	CE_offset	: in std_logic_vector(3 downto 0);
        	RD_WR    	: in std_logic;
        	D_in     	: in std_logic_vector(7 downto 0);
        	D_out    	: out std_logic_vector(7 downto 0)
    	);
	end component;

	-- DUT signals
	signal CE_index_tb   : std_logic := '0';
	signal CE_offset_tb  : std_logic_vector(3 downto 0) := (others => '0');
	signal RD_WR_tb  	: std_logic := '0';
	signal D_in_tb   	: std_logic_vector(7 downto 0) := (others => '0');
	signal D_out_tb  	: std_logic_vector(7 downto 0);
    

begin
	-- Instantiate the Device Under Test (DUT)
	UUT: cache_line_data
    	port map(
        	CE_index	=> CE_index_tb,
        	CE_offset   => CE_offset_tb,
        	RD_WR   	=> RD_WR_tb,
        	D_in    	=> D_in_tb,
        	D_out   	=> D_out_tb
    	);
   	 
	-- Stimulus process
	stim_proc: process
	begin
    	-- Initialize and hold
    	CE_index_tb <= '0'; RD_WR_tb <= '0'; D_in_tb <= X"00"; CE_offset_tb <= "0000";
    	wait for 20 ns;
   	 
    	-- State 3: Write Byte 0 (Data = X"11")
    	-- CE_index on, write enable, D_in is X"11", offset selects Byte 0
    	CE_index_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= X"11"; CE_offset_tb <= "0001";
    	wait for 20 ns;
   	 
    	-- State 4: Read Byte 0 (Expect D_out = X"11")
    	-- CE_index on, read enable. D_in irrelevant.
    	CE_index_tb <= '1'; RD_WR_tb <= '1'; D_in_tb <= X"11"; CE_offset_tb <= "0001";
    	wait for 20 ns;
   	 
   	 
    	-- State 3: Write Byte 0 (Data = X"11")
    	-- CE_index on, write enable, D_in is X"11", offset selects Byte 0
    	CE_index_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= X"AA"; CE_offset_tb <= "0100";
    	wait for 20 ns;
   	 
    	-- State 4: Read Byte 0 (Expect D_out = X"11")
    	-- CE_index on, read enable. D_in irrelevant.
    	CE_index_tb <= '1'; RD_WR_tb <= '1'; D_in_tb <= X"AA"; CE_offset_tb <= "0100";
    	wait for 20 ns;
   	 
    	-- State 3: Write Byte 0 (Data = X"01")
    	-- CE_index on, write enable, D_in is X"11", offset selects Byte 0
    	CE_index_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= X"01"; CE_offset_tb <= "0001";
    	wait for 20 ns;
   	 
    	-- State 4: Read Byte 0 (Expect D_out = X"01")
    	-- CE_index on, read enable. D_in irrelevant.
    	CE_index_tb <= '1'; RD_WR_tb <= '1'; D_in_tb <= X"01"; CE_offset_tb <= "0001";
    	wait for 20 ns;

   	 
    	wait;
	end process;
end tb;
