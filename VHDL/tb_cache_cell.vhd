-- Entity: tb_cache_cell
-- Author: Hannah
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity tb_cache_cell is
end tb_cache_cell;

architecture tb of tb_cache_cell is
	component cache_cell_sr
    	port (
        	CE 	: in std_logic;
        	RD_WR  : in std_logic;
			reset	:in std_logic;
        	D_in   : in std_logic;
        	D_out  : out std_logic
    	);
	end component;

	-- DUT signals
	signal CE_tb, RD_WR_tb, D_in_tb, D_out_tb : std_logic;
begin
	UUT: cache_cell
    	port map(
        	CE  	=> CE_tb,
        	RD_WR   => RD_WR_tb,
			reset  => reset_tb,
        	D_in	=> D_in_tb,
        	D_out   => D_out_tb
    	);
    	stim_proc: process
    	begin
    	-- Chip Enable off, write enable, 0 data
    	CE_tb <= '0'; RD_WR_tb <= '0'; D_in_tb <= '0'; reset_tb <= '1';
    	wait for 20 ns;
    	-- Chip Enable off, read enable, 0 data
    	CE_tb <= '0'; RD_WR_tb <= '1'; D_in_tb <= '0'; reset_tb <= '1';
    	wait for 20 ns;
   	 
    	-- Chip Enable on, write enable, 0 data,
    	CE_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= '0';
    	wait for 20 ns;
    	-- Chip Enable on, read enable, 0 data
    	CE_tb <= '1'; RD_WR_tb <= '1'; D_in_tb <= '0';
    	wait for 20 ns;
   	 
    	-- Chip Enable on, write enable, 1 Data
    	CE_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= '1';
    	wait for 20 ns;
    	-- Chip Enable on, read enable, 1 Data
    	CE_tb <= '1'; RD_WR_tb <= '1'; D_in_tb <= '1';
    	wait for 20 ns;
   	 
            	-- Chip Enable on, write enable, 1 Data
    	CE_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= '1';
    	wait for 40 ns;
   	 
            	-- Chip Enable on, write enable, 1 Data
    	CE_tb <= '1'; RD_WR_tb <= '0'; D_in_tb <= '0';
    	wait for 40 ns;

    	wait;
	end process;
end tb;
