-- Entity: cache_block
-- Architecture: structural
-- Author: Juan Marroquin
--

library IEEE;
use IEEE.std_logic_1164.all;

entity cache_data_block is
  port (
        CE_index     : in std_logic_vector(3 downto 0);
        CE_offset    : in std_logic_vector(3 downto 0);
        RD_WR  : in std_logic;
        Tag_in : in std_logic_vector(1 downto 0);
        Tag_out: out std_logic_vector(1 downto 0);
        V_in   : in std_logic;
        V_out  : out std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end cache_data_block;

architecture structural of cache_block is

  -- Component Declaration (copied from your full_cache_line.vhd)
  component full_cache_line is
    port (
      CE_index     : in  std_logic;
      CE_offset    : in  std_logic_vector(3 downto 0);
      RD_WR        : in  std_logic;
      Tag_in       : in  std_logic_vector(1 downto 0);
      Tag_out      : out std_logic_vector(1 downto 0);
      V_in         : in  std_logic;
      V_out        : out std_logic;
      D_in         : in  std_logic_vector(7 downto 0);
      D_out        : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Configuration (Best Practice)
  for all : full_cache_line use entity work.full_cache_line(structural);

begin

  gen_lines: for i in 0 to 3 generate
    line_inst : full_cache_line
      port map (
        CE_index     => CE_index(i), 
        CE_offset    => CE_offset,
        RD_WR        => RD_WR,
        Tag_in       => Tag_in,
        V_in         => V_in,
        D_in         => D_in,
        Tag_out      => Tag_out,
        V_out        => V_out,
        D_out        => D_out
      );
  end generate gen_lines;

end structural;
