-- Entity: full_cache_line
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity full_cache_line is 
  port (
        CE_index     : in std_logic;
        CE_offset    : in std_logic_vector(3 downto 0);
        RD_WR  : in std_logic;
        Tag_in : in std_logic_vector(1 downto 0);
        Tag_out: out std_logic_vector(1 downto 0);
        V_in   : in std_logic;
        V_out  : out std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end full_cache_line;

architecture structural of full_cache_line is

  -- REQUIRED COMPONENTS
component cache_line_data is 
    port (
        CE_index     : in std_logic;
        CE_offset    : in std_logic_vector(3 downto 0);
        RD_WR  : in std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end component;

 component tag is 
    port (
        CE     : in std_logic;
        RD_WR  : in std_logic;
        Tag_in   : in std_logic_vector(1 downto 0);
        Tag_out  : out std_logic_vector(1 downto 0));
end component;

component valid_bit is 
    port (
        CE     : in std_logic;
        RD_WR  : in std_logic;
        V_in   : in std_logic;
        V_out  : out std_logic);
end component;

for cache_line_data_inst: cache_line_data use entity work.cache_line_data.work(structural);
for tag_inst: tag use entity work.tag.work(structural);
for valid_bit_inst: valid_bit use entity work.valid_bit.work(structural);

  signal CE : std_logic;

  
begin
  CE <= CE_index;
  cache_line_data_inst: cache_line_data port map(CE_index, CE_offset, RD_WR, D_in, D_out);
  tag_inst: tag port map(CE,RD_WR, Tag_in, Tag_out);
  valid_bit_inst: valid_bit port map(CE, RD_WR, V_in, V_out);

end structural;

  
