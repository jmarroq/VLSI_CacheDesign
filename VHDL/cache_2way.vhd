library IEEE;
use IEEE.std_logic_1164.all;

entity cache_2way is
    port (
        -- CPU Interface
        cpu_add    : in    std_logic_vector(5 downto 0);
        cpu_data   : inout std_logic_vector(7 downto 0);
        cpu_rd_wrn : in    std_logic;   -- 1 = READ, 0 = WRITE
        start      : in    std_logic;
        clk        : in    std_logic;
        reset      : in    std_logic;

        -- Memory Interface
        mem_data   : in    std_logic_vector(7 downto 0);
        mem_add    : out   std_logic_vector(5 downto 0);

        -- Power & Status
        Vdd        : in    std_logic;
        Gnd        : in    std_logic;
        busy       : out   std_logic;
        mem_en     : out   std_logic
    );
end cache_2way;

architecture structural of cache_2way is

    ----------------------------------------------------------------
    -- Internal Signals
    ----------------------------------------------------------------
    -- Registered CPU data/address
    signal Reg_Data_Q       : std_logic_vector(7 downto 0);
    signal Reg_Addr_Q       : std_logic_vector(5 downto 0);

    -- Address fields
    signal Tag_Bits         : std_logic_vector(1 downto 0);
    signal Index_Bits       : std_logic_vector(1 downto 0);
    signal Byte_Offset_Bits : std_logic_vector(1 downto 0);

    -- Decoders outputs
    signal Index_Dec_Y : std_logic_vector(3 downto 0);
    signal Byte_Dec_Y  : std_logic_vector(3 downto 0);

    -- Cache way outputs
    signal data_way0, data_way1 : std_logic_vector(7 downto 0);
    signal hit_way0, hit_way1   : std_logic;
    signal tag0, tag1           : std_logic_vector(1 downto 0);
    signal valid0, valid1       : std_logic;

    -- LRU
    signal LRU_bit : std_logic;

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
    signal FSM_Latch_En         : std_logic;

    -- Tri-state inverted enables
    signal FSM_CPU_Out_En_NOT      : std_logic;
    signal FSM_MemAddr_Out_En_NOT  : std_logic;

    -- Internal CPU/Mem data lines
    signal CPU_Data_Int    : std_logic_vector(7 downto 0);
    signal Mem_Addr_Line   : std_logic_vector(5 downto 0);

begin
    ----------------------------------------------------------------
    -- Registers
    ----------------------------------------------------------------
    Data_Reg_Inst : entity work.reg8
        port map (
            D      => cpu_data,
            CLK    => clk,
            RESET  => reset,
            ENABLE => FSM_Latch_En,
            Q      => Reg_Data_Q
        );

    Addr_Reg_Inst : entity work.reg6
        port map (
            D      => cpu_add,
            CLK    => clk,
            RESET  => reset,
            ENABLE => FSM_Latch_En,
            Q      => Reg_Addr_Q
        );

    ----------------------------------------------------------------
    -- Address decoding
    ----------------------------------------------------------------
    Tag_Bits         <= Reg_Addr_Q(5 downto 4);
    Index_Bits       <= Reg_Addr_Q(3 downto 2);
    Byte_Offset_Bits <= Reg_Addr_Q(1 downto 0);

    Index_Dec_Inst : entity work.decoder2to4
        port map (
            EN => FSM_Decoder_Enable,
            A  => Index_Bits,
            Y  => Index_Dec_Y
        );

    Offset_Dec_Inst : entity work.decoder2to4
        port map (
            EN => FSM_Decoder_Enable,
            A  => Byte_Offset_Bits,
            Y  => Byte_Dec_Y
        );

    ----------------------------------------------------------------
    -- Cache ways
    ----------------------------------------------------------------
    Way0 : entity work.cache_way
        port map (
            CE_index  => Byte_Dec_Y,
            CE_offset => Index_Dec_Y,
            RD_WR     => FSM_RW_Enable,
            reset     => reset,
            Tag_in    => Tag_Bits,
            V_in      => FSM_Valid_Bit,
            D_in      => Reg_Data_Q,
            D_out     => data_way0,
            Tag_out   => tag0,
            V_out     => valid0,
            hit       => hit_way0
        );

    Way1 : entity work.cache_way
        port map (
            CE_index  => Byte_Dec_Y,
            CE_offset => Index_Dec_Y,
            RD_WR     => FSM_RW_Enable,
            reset     => reset,
            Tag_in    => Tag_Bits,
            V_in      => FSM_Valid_Bit,
            D_in      => Reg_Data_Q,
            D_out     => data_way1,
            Tag_out   => tag1,
            V_out     => valid1,
            hit       => hit_way1
        );

    ----------------------------------------------------------------
    -- LRU logic
    ----------------------------------------------------------------
    LRU_Inst : entity work.lru_logic
        port map (
            clk      => clk,
            reset    => reset,
            rd_wrn   => FSM_RW_Enable,
            hit_way0 => hit_way0,
            hit_way1 => hit_way1,
            LRU_out  => LRU_bit
        );

    ----------------------------------------------------------------
    -- CPU data selection (mux2to1_8bit)
    ----------------------------------------------------------------
    CPU_Data_Mux : entity work.mux2to1_8bit
        port map (
            S  => LRU_bit,
            I0 => data_way0,
            I1 => data_way1,
            Y  => CPU_Data_Int
        );

    ----------------------------------------------------------------
    -- Tri-state connection to CPU
    ----------------------------------------------------------------
    FSM_CPU_Out_En_NOT     <= not FSM_CPU_Out_En;

    Tx_CPU_Data : entity work.tx_8bit
        port map (
            sel    => FSM_CPU_Out_En,
            selnot => FSM_CPU_Out_En_NOT,
            input  => CPU_Data_Int,
            output => cpu_data
        );

    ----------------------------------------------------------------
    -- FSM Controller
    ----------------------------------------------------------------
    FSM_Inst : entity work.cache_fsm_struct
        port map (
            clk             => clk,
            reset           => reset,
            start           => start,
            read_write      => cpu_rd_wrn,
            cvt             => FSM_Cvt_In,
            busy            => busy,
            output_enable   => FSM_CPU_Out_En,
            rw_enable       => FSM_RW_Enable,
            mux_sel         => FSM_Mux_Sel,
            decoder_enable  => FSM_Decoder_Enable,
            mem_enable      => FSM_Mem_Enable,
            valid_bit       => FSM_Valid_Bit,
            byte_cnt_out    => FSM_Byte_Counter,
            latch_en        => FSM_Latch_En
        );

    ----------------------------------------------------------------
    -- CVT (compare tag + valid) for hit/miss
    ----------------------------------------------------------------
    CVT_Way0 : entity work.cvt
        port map (
            input1 => Tag_Bits,
            input2 => tag0,
            valid  => valid0,
            output => FSM_Cvt_In  -- fed to FSM
        );

    ----------------------------------------------------------------
    -- Memory interface
    ----------------------------------------------------------------
    mem_add <= Reg_Addr_Q;
    mem_en  <= FSM_Mem_Enable;

end architecture;
