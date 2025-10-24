-- Entity: cache
-- Architecture: structural
-- Author: Juan Marroquin
--


library IEEE;
use IEEE.std_logic_1164.all;

entity cache is
    port (
       -- I/0 vectors
        CPU_Data       : in std_logic_vector(7 downto 0);
        CPU_Address    : in std_logic_vector(7 downto 0);
        Memory_Data    : in std_logic_vector(7 downto 0);
        Memory_Address : in std_logic_vector(7 downto 0);
      -- Control Signals
       read_write      : in std_logic;
       start           : in std_logic;
       reset           : in std_logic;  
       clk             : in std_logic;
       busy            : out std_logic;
       mem_enable      : out std_logic;
end cache;
architectural structural of cache is

-- REQUIRED COMPONENTS
  component cache is
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
  end component;

component cache_data_block is
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
end component;
--------------------------------------------------------------------------------
-- DECODER AND MUXES
--------------------------------------------------------------------------------
component decoder2to4 is 
    port (
        EN    : in std_logic;
        A    : in std_logic_vector(1 downto 0);
        Y  : out std_logic_vector(3 downto 0));
end component;
        
component mux2to1_8bit is
  port (
    S   : in  std_logic;
    I0  : in  std_logic_vector(7 downto 0);
    I1  : in  std_logic_vector(7 downto 0);
    Y   : out std_logic_vector(7 downto 0)
  );
end component;

component mux2to1_2bit is
  port (
    S   : in  std_logic;
    I0  : in  std_logic_vector(1 downto 0);
    I1  : in  std_logic_vector(1 downto 0);
    Y   : out std_logic_vector(1 downto 0)
  );
end component;

--------------------------------------------------------------------------------
-- REGISTERS AND HELPERS
--------------------------------------------------------------------------------
component reg8 is
  port (
    D    : in  std_logic_vector(7 downto 0);
    CLK  : in  std_logic;
    RESET: in  std_logic;
    Q    : out std_logic_vector(7 downto 0)
  );
end component;
       
component cvt is
  port (
    input1   : in std_logic_vector(1 downto 0); -- input Tag[1:0]
    input2   : in std_logic_vector(1 downto 0); -- input cache Tag[1:0]
    valid   : in std_logic; -- valid bit
    output   : out std_logic); -- hit / miss
end component;

        

    

  
      
        
        
