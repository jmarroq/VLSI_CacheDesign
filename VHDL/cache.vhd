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

  
      
        
        
