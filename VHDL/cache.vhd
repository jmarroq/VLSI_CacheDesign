-- ============================================================
-- Entity: cache
-- Architecture: structural
-- Author: Juan Marroquin
-- Description: Top-level structural cache integrating FSM,
--              data path, and memory interface.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity cache is
    port (
        -- CPU and Memory Interfaces
        CPU_Data        : inout std_logic_vector(7 downto 0);
        CPU_Address     : in    std_logic_vector(7 downto 0);
        Memory_Data     : inout std_logic_vector(7 downto 0);
        Memory_Address  : out   std_logic_vector(7 downto 0);

        -- Control
        read_write      : in  std_logic;
        start           : in  std_logic;
        reset           : in  std_logic;
        clk             : in  std_logic;

        -- Status
        busy            : out std_logic;
        mem_enable      : out std_logic
    );
end cache;

architecture structural of cache is

    ----------------------------------------------------------------
    -- Internal Signals
    ----------------------------------------------------------------
    -- Registered data/address
    signal Reg_Data_Q       : std_logic_vector(7 downto 0);
    signal Reg_Addr_Q       : std_logic_vector(7 downto 0);

    -- Mux outputs
    signal Mux_8bit_Out     : std_logic_vector(7 downto 0);
    signal Cache_Data_Out   : std_logic_vector(7 downto 0);
    signal Mux_2bit_Out     : std_logic_vector(1 downto 0);

    -- Address fields
    signal Tag_Bits         : std_logic_vector(1 downto 0);
    signal Index_Bits       : std_logic_vector(1 downto 0);
    signal Byte_Offset_Bits : std_logic_vector(1 downto 0);

    -- FSM control lines
    signal FSM_Cvt_In           : std_logic;
    signal FSM_CPU_Out_En       : std_logic;
    signal FSM_MemAddr_Out_En   : std_logic;
    signal FSM_RW_Enable        : std_logic;
    signal FSM_Mux_Sel          : std_logic;
    signal FSM_Decoder_Enable   : std_logic;
    signal FSM_Mem_Enable       : std_logic;
    signal FSM_Valid_Bit        : std_logic;
    signal FSM_Byte_Counter     : std_logic_vector(1 downto 0);

    -- Decoder enables
    signal Index_Dec_Y          : std_logic_vector(3 downto 0);
    signal Byte_Dec_Y           : std_logic_vector(3 downto 0);

    -- Cache status
    signal Cache_Tag_Out        : std_logic_vector(1 downto 0);
    signal Cache_Valid_Out      : std_logic;

    -- Tri-state inverted enables
    signal FSM_CPU_Out_En_NOT      : std_logic;
    signal FSM_MemAddr_Out_En_NOT  : std_logic;

    -- Data to CPU / Mem
    signal CPU_Data_Int    : std_logic_vector(7 downto 0);
    signal Mem_Addr_Line   : std_logic_vector(7 downto 0);

begin
    ----------------------------------------------------------------
    -- Address field extraction
    ----------------------------------------------------------------
    Tag_Bits         <= Reg_Addr_Q(7 downto 6);
    Index_Bits       <= Reg_Addr_Q(5 downto 4);
    Byte_Offset_Bits <= Reg_Addr_Q(3 downto 2);

    -- Hardcoded memory address: upper nibble = "1100"
    Mem_Addr_Line <= "1100" & CPU_Address(3 downto 0);

    FSM_CPU_Out_En_NOT     <= not FSM_CPU_Out_En;
    FSM_MemAddr_Out_En_NOT <= not FSM_MemAddr_Out_En;

    ----------------------------------------------------------------
    -- FSM Controller
    ----------------------------------------------------------------
    FSM_Inst : entity work.cache_fsm_struct
        port map (
            clk             => clk,
            reset           => reset,
            start           => start,
            read_write      => read_write,
            cvt             => FSM_Cvt_In,
            busy            => busy,
            output_enable   => FSM_CPU_Out_En,
            rw_enable       => FSM_RW_Enable,
            mux_sel         => FSM_Mux_Sel,
            decoder_enable  => FSM_Decoder_Enable,
            mem_enable      => FSM_Mem_Enable,
            valid_bit       => FSM_Valid_Bit,
            byte_cnt_out    => FSM_Byte_Counter
        );

    ----------------------------------------------------------------
    -- Registers
    ----------------------------------------------------------------
    Data_Reg_Inst : entity work.reg8
      port map (
        D      => CPU_Data,
        CLK    => clk,
        RESET  => reset,
        ENABLE => '1',
        Q      => Reg_Data_Q
      );

    Addr_Reg_Inst : entity work.reg8
      port map (
        D      => CPU_Address,
        CLK    => clk,
        RESET  => reset,
        ENABLE => '1',
        Q      => Reg_Addr_Q
      );


    ----------------------------------------------------------------
    -- 8-bit Data Mux (S=1 -> CPU) 2-bit Offset Mux 
    ----------------------------------------------------------------
    Data_Mux_Inst : entity work.mux2to1_8bit
        port map (
            S  => FSM_Mux_Sel,
            I0 => Memory_Data,    -- Memory when 0
            I1 => Reg_Data_Q,     -- CPU when 1
            Y  => Mux_8bit_Out
        );

    Offset_Mux_Inst : entity work.mux2to1_2bit
        port map (
            S  => FSM_Mux_Sel,
            I0 => FSM_Byte_Counter,
            I1 => Byte_Offset_Bits,
            Y  => Mux_2bit_Out
        );

    ----------------------------------------------------------------
    -- Decoders
    ----------------------------------------------------------------
    Index_Dec_Inst : entity work.decoder2to4
        port map (
            EN => FSM_Decoder_Enable,
            A  => Index_Bits,
            Y  => Index_Dec_Y
        );

    Offset_Dec_Inst : entity work.decoder2to4
        port map (
            EN => FSM_Decoder_Enable,
            A  => Mux_2bit_Out,
            Y  => Byte_Dec_Y
        );

    ----------------------------------------------------------------
    -- Cache Data Block
    ----------------------------------------------------------------
        Cache_Block_Inst : entity work.cache_data_block
        port map (
        	CE_index  => Index_Dec_Y,
            CE_offset => Byte_Dec_Y,
            RD_WR     => FSM_RW_Enable,
            reset     => reset,          
            Tag_in    => Tag_Bits,
            Tag_out   => Cache_Tag_Out,
            V_in      => FSM_Valid_Bit,
            V_out     => Cache_Valid_Out,
            D_in      => Mux_8bit_Out,
            D_out     => Cache_Data_Out
        );
    ----------------------------------------------------------------
    -- Tag + Valid Comparator
    ----------------------------------------------------------------
    Cvt_Inst : entity work.cvt
        port map (
            input1 => Tag_Bits,
            input2 => Cache_Tag_Out,
            valid  => Cache_Valid_Out,
            output => FSM_Cvt_In
        );

    ----------------------------------------------------------------
    -- Tri-state Outputs
    ----------------------------------------------------------------
    -- (1) CPU Data Bus
    Tx_CPU_Data : entity work.tx_8bit
        port map (
            sel    => FSM_CPU_Out_En,
            selnot => FSM_CPU_Out_En_NOT,
            input  => Cache_Data_Out,
            output => CPU_Data
        );

    -- (2) Memory Address Bus
    Tx_Mem_Addr : entity work.tx_8bit
        port map (
            sel    => FSM_MemAddr_Out_En,
            selnot => FSM_MemAddr_Out_En_NOT,
            input  => Mem_Addr_Line,
            output => Memory_Address
        );

    ----------------------------------------------------------------
    -- Output Assignments
    ----------------------------------------------------------------
    mem_enable <= FSM_Mem_Enable;

end structural;
