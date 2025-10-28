-- Entity: cache
-- Architecture: structural

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
    input1   : in std_logic_vector(1 downto 0); 
    input2   : in std_logic_vector(1 downto 0);
    valid   : in std_logic; 
    output   : out std_logic); 
end component;

component tx_8bit is
    port (
        sel   : in std_logic;  
        selnot: in std_logic;  
        input : in std_logic_vector(7 downto 0); 
        output: out std_logic_vector(7 downto 0)
    );
end component;
--------------------------------------------------------------------------------
-- INTERNAL SIGNAL DECLARATIONS (WIRES)
--------------------------------------------------------------------------------

    -- 8-bit Data/Address Signals
    signal Reg_Data_Q       : std_logic_vector(7 downto 0);
    signal Reg_Addr_Q       : std_logic_vector(7 downto 0);
    signal Mux_8bit_Out     : std_logic_vector(7 downto 0);
    signal Cache_Data_Out   : std_logic_vector(7 downto 0);
    
    -- Address Decomposition Signals (from Reg_Addr_Q)
    -- Assuming a 2-bit Tag, 2-bit Index, 2-bit Byte Offset (6 relevant bits)
    signal Tag_Bits         : std_logic_vector(1 downto 0);  -- Bits 7, 6
    signal Index_Bits       : std_logic_vector(1 downto 0);  -- Bits 5, 4
    signal Byte_Offset_Bits : std_logic_vector(1 downto 0);  -- Bits 3, 2

    -- 2-bit Mux Signal
    signal Mux_2bit_Out     : std_logic_vector(1 downto 0);

    -- FSM Control Signals
    signal FSM_Cvt_In       : std_logic;
    signal FSM_Output_Enable: std_logic;
    signal FSM_Write_Enable : std_logic;
    signal FSM_Data_Mux_Sel : std_logic;
    signal FSM_Decoder_Enable: std_logic;
    signal FSM_Byte_Counter : std_logic_vector(1 downto 0);

    -- Cache Block Status Signals
    signal Cache_Tag_Out    : std_logic_vector(1 downto 0);
    signal Cache_Valid_Out  : std_logic;

    -- Decoder Outputs (4-bit enables)
    signal Index_Dec_Y      : std_logic_vector(3 downto 0);
    signal Byte_Dec_Y       : std_logic_vector(3 downto 0);

    -- Inverter for the Tri-State Buffer (tx_8bit)
    signal FSM_Output_Enable_NOT : std_logic;

--------------------------------------------------------------------------------
-- SIGNAL ASSIGNMENTS (ADDRESS DECOMPOSITION)
--------------------------------------------------------------------------------

    -- Tag: Reg_Addr_Q(7 downto 6)
    Tag_Bits <= Reg_Addr_Q(7 downto 6);
    -- Index: Reg_Addr_Q(5 downto 4)
    Index_Bits <= Reg_Addr_Q(5 downto 4);
    -- Byte Offset: Reg_Addr_Q(3 downto 2)
    Byte_Offset_Bits <= Reg_Addr_Q(3 downto 2);

    -- Inverter for the tri-state buffer's selnot pin
    FSM_Output_Enable_NOT <= not FSM_Output_Enable;

    -- Tie the FSM outputs to the top-level entity outputs
    busy <= busy; 
    mem_enable <= FSM_Memory_Enable; 
        
--------------------------------------------------------------------------------
-- COMPONENT INSTANTIATION AND PORT MAPPING
--------------------------------------------------------------------------------

    -- 1. FSM INSTANTIATION
    FSM_Inst : entity work.cache_fsm 
        port map (
            clk             => clk,
            reset           => reset,
            start           => start,
            read_write      => read_write,
            cvt             => FSM_Cvt_In,
            busy            => busy,
            output_enable   => FSM_Output_Enable,
            write_enable    => FSM_Write_Enable,
            data_mux_sel    => FSM_Data_Mux_Sel,
            decoder_enable  => FSM_Decoder_Enable,
            memory_enable   => mem_enable,
            valid_bit		=> FSM_Valid_Bit,
            byte_cnt_out    => FSM_Byte_Counter
        );

    -- 2. DATA AND ADDRESS REGISTERS (reg8)
    Data_Reg_Inst : entity work.reg8
        port map (
            D    => CPU_Data,
            CLK  => clk,
            RESET=> reset,
            Q    => Reg_Data_Q
        );

    Addr_Reg_Inst : entity work.reg8
        port map (
            D    => CPU_Address,
            CLK  => clk,
            RESET=> reset,
            Q    => Reg_Addr_Q
        );

    -- 3. 8-BIT DATA MUX (mux2to1_8bit)
    Data_Mux_Inst : entity work.mux2to1_8bit
        port map (
            S   => FSM_Data_Mux_Sel,
            I0  => Reg_Data_Q,    -- Registered CPU Data
            I1  => Memory_Data,   -- Data from Memory
            Y   => Mux_8bit_Out   -- To Cache D_in
        );

    -- 4. 2-BIT BYTE OFFSET MUX (mux2to1_2bit)
    Offset_Mux_Inst : entity work.mux2to1_2bit
        port map (
            S   => FSM_Data_Mux_Sel, 
            I0  => Byte_Offset_Bits, -- CPU Byte Offset 
            I1  => FSM_Byte_Counter, -- FSM's Byte Counter 
            Y   => Mux_2bit_Out      -- To Byte Offset Decoder
        );

    -- 5. INDEX DECODER (decoder2to4)
    Index_Dec_Inst : entity work.decoder2to4
        port map (
            EN  => FSM_Decoder_Enable,
            A   => Index_Bits,         
            Y   => Index_Dec_Y        
        );

    -- 6. BYTE OFFSET DECODER (decoder2to4)
    Offset_Dec_Inst : entity work.decoder2to4
        port map (
            EN  => FSM_Decoder_Enable,
            A   => Mux_2bit_Out,       
            Y   => Byte_Dec_Y         
        );

    -- 7. CACHE BLOCK (cache_data_block)
    Cache_Block_Inst : entity work.cache_data_block
        port map (
            CE_index     => Index_Dec_Y,       -- Index Decoder output
            CE_offset    => Byte_Dec_Y,        -- Byte Offset Decoder output
            RD_WR        => FSM_Write_Enable,  -- Controlled by FSM (Inverted read_write)
            Tag_in       => Tag_Bits,          -- 2-bit Tag from address register
            Tag_out      => Cache_Tag_Out,     -- To CVT
            V_in         => FSM_Valid_Bit,     -- Valid bit control from FSM
            V_out        => Cache_Valid_Out,   -- To CVT
            D_in         => Mux_8bit_Out,      -- Data from 8-bit Mux
            D_out        => Cache_Data_Out     -- To Tri-State Buffer
        );

    -- 8. TAG/VALID CHECKER (cvt)
    Cvt_Inst : entity work.cvt
        port map (
            input1   => Tag_Bits,              -- Tag from address register
            input2   => Cache_Tag_Out,         -- Tag from Cache Block
            valid    => Cache_Valid_Out,       -- Valid bit from Cache Block
            output   => FSM_Cvt_In             -- To FSM's cvt input (Hit/Miss)
        );

    -- 9. TRI-STATE BUFFER (tx_8bit)
    Tx_8bit_Inst : entity work.tx_8bit
        port map (
            sel   => FSM_Output_Enable,
            selnot=> FSM_Output_Enable_NOT,
            input => Cache_Data_Out,           
            output=> CPU_Data_Out              
        );

end structural;

        

    

  
      
        
        
