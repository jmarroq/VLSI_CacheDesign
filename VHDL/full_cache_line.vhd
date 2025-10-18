-- Entity: full_cache_line
-- Architecture: structural
-- Author: Juan Marroquin
--

entity full_cache_line is 
  port (
        CE_index     : in std_logic;
        CE_offset    : in std_logic_vector(3 downto 0);
        RD_WR  : in std_logic;
        V_in   : in std_logic;
        Tag_in : in std_logic_vector(1 downto 0);
        D_in   : in std_logic_vector(7 downto 0);
        V_out  : out std_logic;
        Tag_out: out std_logic_vector(1 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end full_cache_line;

architecture structural of full_cache_line is

component cache_line_data is 
    port (
        CE_index     : in std_logic;
        CE_offset    : in std_logic_vector(3 downto 0);
        RD_WR  : in std_logic;
        D_in   : in std_logic_vector(7 downto 0);
        D_out  : out std_logic_vector(7 downto 0));
end component;

