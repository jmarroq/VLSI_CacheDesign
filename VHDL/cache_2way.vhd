library IEEE;
use IEEE.std_logic_1164.all;

entity cache_2way is
	port (
    	-- CPU Interface
    	cpu_add	: in	std_logic_vector(5 downto 0);
    	cpu_data   : inout std_logic_vector(7 downto 0);
    	cpu_rd_wrn : in	std_logic;   -- 1 = READ, 0 = WRITE
    	start  	: in	std_logic;
    	clk    	: in	std_logic;
    	reset  	: in	std_logic;

    	-- Memory Interface
    	mem_data   : in	std_logic_vector(7 downto 0);
    	mem_add	: out   std_logic_vector(5 downto 0);

    	-- Power & Status
    	Vdd    	: in	std_logic;
    	Gnd    	: in	std_logic;
    	busy   	: out   std_logic;
    	mem_en 	: out   std_logic
	);
end cache_2way;

architecture structural of cache_2way is

	----------------------------------------------------------------
	-- Internal Signals
	----------------------------------------------------------------
	signal Reg_Data_Q   	: std_logic_vector(7 downto 0);
	signal Reg_Addr_Q   	: std_logic_vector(5 downto 0);

	signal Tag_Bits     	: std_logic_vector(1 downto 0);
	signal Index_Bits   	: std_logic_vector(1 downto 0);
	signal Byte_Offset_Bits : std_logic_vector(1 downto 0);

	signal Index_Dec_Y : std_logic_vector(3 downto 0);  -- line select
	signal Byte_Dec_Y  : std_logic_vector(3 downto 0);  -- byte select

	signal data_way0, data_way1 : std_logic_vector(7 downto 0);
	signal tag0, tag1       	: std_logic_vector(1 downto 0);
	signal valid0, valid1   	: std_logic;
	signal hit0, hit1       	: std_logic;
	signal hit_any_way      	: std_logic;

	signal LRU_bit, updated_lru_bit : std_logic;
	signal mux_out              	: std_logic;

	signal CPU_Data_Int     	: std_logic_vector(7 downto 0);
	signal D_in_way0, D_in_way1 : std_logic_vector(7 downto 0);

	signal write_data_bus : std_logic_vector(7 downto 0);

	-- per-way RD/WR (to stop clobbering the other way)
	signal RD_WR_way0, RD_WR_way1 : std_logic;

	-- FSM signals
	signal FSM_CPU_Out_En, FSM_RW_Enable, FSM_Mem_Enable, FSM_Valid_Bit : std_logic;
	signal FSM_Latch_En, FSM_Mux_Sel, FSM_Decoder_Enable : std_logic;
	signal FSM_Byte_Counter : std_logic_vector(1 downto 0);
	signal Mux_2bit_Out 	: std_logic_vector(1 downto 0);

	-- busy signals
	signal busy_internal : std_logic;
	signal busy_d    	: std_logic;
	signal not_busy  	: std_logic;
	signal busy_edge 	: std_logic;
    
    
	--lru signals
	signal hit0_not      	: std_logic;
	signal hit1_not      	: std_logic;

	signal hit0_only     	: std_logic;  -- hit0=1 & hit1=0
	signal hit1_only     	: std_logic;  -- hit1=1 & hit0=0

	signal lru_after_hit0	: std_logic;  -- output of first mux (hit0 stage)
 
	signal lru_d_in      	: std_logic;  -- input to LRU DFF after busy_edge mux
    
	--way selection
 	signal xor_hits : std_logic;
 	signal hit0_r, hit1_r : std_logic;
 	signal LRU_r :std_logic;

signal hit0_d, hit1_d : std_logic;

signal en_not0, en_not1 : std_logic;
signal en_hit0, en_hit1 : std_logic;
signal hold_hit0, hold_hit1 : std_logic;


   	 
	-- per way write signals
	signal FSM_RW_Enable_not : std_logic;
	signal mux_out_not   	: std_logic;
	signal wr0_sel : std_logic;  
	signal wr1_sel : std_logic;



begin

	----------------------------------------------------------------
	-- Registers for CPU address/data
	----------------------------------------------------------------
	Data_Reg_Inst : entity work.reg8
    	port map (
        	D  	=> cpu_data,
        	CLK	=> clk,
        	RESET  => reset,
        	ENABLE => FSM_Latch_En,
        	Q  	=> Reg_Data_Q
    	);

	Addr_Reg_Inst : entity work.reg6
    	port map (
        	D  	=> cpu_add,
        	CLK	=> clk,
        	RESET  => reset,
        	ENABLE => FSM_Latch_En,
        	Q  	=> Reg_Addr_Q
    	);

	----------------------------------------------------------------
	-- Address field split
	----------------------------------------------------------------
	Tag_Bits     	<= Reg_Addr_Q(5 downto 4);
	Index_Bits   	<= Reg_Addr_Q(3 downto 2);
	Byte_Offset_Bits <= Reg_Addr_Q(1 downto 0);

	----------------------------------------------------------------
	-- Decoders
	----------------------------------------------------------------
	-- Index decoder: selects which of the 4 lines (index)
	Index_Dec_Inst : entity work.decoder2to4
    	port map (
        	EN => FSM_Decoder_Enable,
        	A  => Index_Bits,
        	Y  => Index_Dec_Y
    	);


   Offset_Mux_Inst : entity work.mux2to1_2bit
    	port map (
        	S  => FSM_Mux_Sel,
        	I0 => FSM_Byte_Counter,
        	I1 => Byte_Offset_Bits,
        	Y  => Mux_2bit_Out
    	);

	-- Byte decoder: selects which byte in the line (offset)
	Offset_Dec_Inst : entity work.decoder2to4
    	port map (
        	EN => FSM_Decoder_Enable,
        	A  => Mux_2bit_Out,
        	Y  => Byte_Dec_Y
    	);

	----------------------------------------------------------------
	-- Cache ways
	----------------------------------------------------------------
	Way0 : entity work.cache_data_block
    	port map (
        	CE_index  => Index_Dec_Y,   -- line select
        	CE_offset => Byte_Dec_Y,	-- byte select
        	RD_WR 	=> RD_WR_way0,
        	reset 	=> reset,
        	Tag_in	=> Tag_Bits,
        	Tag_out   => tag0,
        	V_in  	=> FSM_Valid_Bit,
        	V_out 	=> valid0,
        	D_in  	=> D_in_way0,
        	D_out 	=> data_way0
    	);

	Way1 : entity work.cache_data_block
    	port map (
        	CE_index  => Index_Dec_Y,
        	CE_offset => Byte_Dec_Y,
        	RD_WR 	=> RD_WR_way1,
        	reset 	=> reset,
        	Tag_in	=> Tag_Bits,
        	Tag_out   => tag1,
        	V_in  	=> FSM_Valid_Bit,
        	V_out 	=> valid1,
        	D_in  	=> D_in_way1,
        	D_out 	=> data_way1
    	);

	----------------------------------------------------------------
	-- CVT hit detection
	----------------------------------------------------------------
	CVT0_Inst : entity work.cvt
    	port map (input1 => Tag_Bits, input2 => tag0, valid => valid0, output => hit0);

	CVT1_Inst : entity work.cvt
    	port map (input1 => Tag_Bits, input2 => tag1, valid => valid1, output => hit1);

	hit_any_way <= hit0 or hit1;

	----------------------------------------------------------------
	-- busy edge detection
	----------------------------------------------------------------
	-- busy_d : DFF storing previous busy_internal
	busy_dff : entity work.dff_pos
    	port map (
    	clk   => clk,
    	reset => reset,
    	d 	=> busy_internal,
    	q 	=> busy_d
    	);

	-- not_busy = NOT busy_internal
	inv_busy : entity work.inverter
    	port map (
    	input  => busy_internal,
    	output => not_busy
    	);

	-- busy_edge = (not_busy) AND (busy_d)
	--   = (busy_internal = 0 now) AND (busy_internal = 1 last cycle)
	busy_edge_and : entity work.and2
    	port map (
    	input1 => not_busy,
    	input2 => busy_d,
    	output => busy_edge
    	);


	----------------------------------------------------------------
	-- LRU (behavioral)
	----------------------------------------------------------------
    	----------------------------------------------------------------
	-- Inverters for hit bits
	----------------------------------------------------------------
	inv_hit0 : entity work.inverter
    	port map (
    	input  => hit0,
    	output => hit0_not
    	);

	inv_hit1 : entity work.inverter
    	port map (
    	input  => hit1,
    	output => hit1_not
    	);

	----------------------------------------------------------------
	-- Detect hit0 only  (hit0=1 and hit1=0)
	----------------------------------------------------------------
	hit0_only_and : entity work.and2
    	port map (
    	input1 => hit0,
    	input2 => hit1_not,
    	output => hit0_only
    	);

	----------------------------------------------------------------
	-- Detect hit1 only  (hit1=1 and hit0=0)
	----------------------------------------------------------------
	hit1_only_and : entity work.and2
    	port map (
    	input1 => hit1,
    	input2 => hit0_not,
    	output => hit1_only
    	);

	----------------------------------------------------------------
	-- MUX A: select between WAY0_MRU (=1) and LRU_BIT (hold)
	-- Select = hit0_only
	----------------------------------------------------------------
	mux_way0 : entity work.mux2to1
    	port map (
    	S  => hit0_only,
    	I0 => LRU_bit,   -- hold
    	I1 => '1',   	-- way0 MRU makes LRU=1
    	Y  => lru_after_hit0
    	);

	----------------------------------------------------------------
	-- MUX B: select between WAY1_MRU (=0) and previous result
	-- Select = hit1_only
	----------------------------------------------------------------
	mux_way1 : entity work.mux2to1
    	port map (
    	S  => hit1_only,
    	I0 => lru_after_hit0,  -- carry previous logic
    	I1 => '0',         	-- way1 MRU makes LRU=0
    	Y  => updated_lru_bit
    	);

	----------------------------------------------------------------
	-- MUX C: write LRU only on busy_edge
	-- Equivalent to "if busy_edge=1 then updated else hold"
	----------------------------------------------------------------
	lru_ce_mux : entity work.mux2to1
    	port map (
    	S  => busy_edge,
    	I0 => LRU_bit,     	-- hold
    	I1 => updated_lru_bit, -- update
    	Y  => lru_d_in
    	);

	----------------------------------------------------------------
	-- DFF (positive edge): final LRU register
	----------------------------------------------------------------
	lru_dff : entity work.dff_pos
    	port map (
    	clk   => clk,
    	reset => reset,
    	d 	=> lru_d_in,
    	q 	=> LRU_bit
    	);


	----------------------------------------------------------------
	-- Way selection for muxes and write gating
	----------------------------------------------------------------
	
		
	-- Enable-gated D logic for hit0_r
	

	--- en_not0 = NOT(FSM_Latch_En)
	u_not_en0 : entity work.inverter port map(
	    input  => FSM_Latch_En,
	    output  => en_not0
	);

	-- en_hit0 = FSM_Latch_En AND hit0
	u_and_en_hit0 : entity work.and2 port map(
	    input1  => FSM_Latch_En,
	    input2  => hit0,
	    output  => en_hit0
	);

	-- hold_hit0 = en_not0 AND hit0_r
	u_and_hold_hit0 : entity work.and2 port map(
	    input1  => en_not0,
	    input2  => hit0_r,
	    output  => hold_hit0
	);

	-- hit0_d = en_hit0 OR hold_hit0
	u_or_hit0_d : entity work.or2 port map(
	    input1  => en_hit0,
	    input2  => hold_hit0,
	    output  => hit0_d
	);


	
	-- Enable-gated D logic for hit1_r
	

	-- en_not1 = NOT(FSM_Latch_En)
	u_not_en1 : entity work.inverter port map(
	    input  => FSM_Latch_En,
	    output  => en_not1
	);

	-- en_hit1 = FSM_Latch_En AND hit1
	u_and_en_hit1 : entity work.and2 port map(
	    input1  => FSM_Latch_En,
	    input2  => hit1,
	    output  => en_hit1
	);

	-- hold_hit1 = en_not1 AND hit1_r
	u_and_hold_hit1 : entity work.and2 port map(
	    input1  => en_not1,
	    input2  => hit1_r,
	    output  => hold_hit1
	);

	-- hit1_d = en_hit1 OR hold_hit1
	u_or_hit1_d : entity work.or2 port map(
	    input1  => en_hit1,
	    input2  => hold_hit1,
	    output  => hit1_d
	);


		
	-- Actual flip-flops for registered hits (falling-edge)
	

	hit0_ff : entity work.dff_neg
	    port map(
		clk   => clk,
		d     => hit0_d,
		reset => reset,
		q     => hit0_r
	    );

	hit1_ff : entity work.dff_neg
	    port map(
		clk   => clk,
		d     => hit1_d,
		reset => reset,
		q     => hit1_r
	    );

	
	u_xor_hits : entity work.xor2 port map(
	    input1 => hit0_r,
	    input2 => hit1_r,
	    output => xor_hits
	);

	-- Final way-selection mux:
	-- xor_hits = '1' → hit case (way = hit1)
	-- xor_hits = '0' → else case (LRU_bit) for 00 or 11
	u_mux_way_select : entity work.mux2to1 port map(
	    I0 => LRU_bit,   -- miss or double-hit
	    I1 => hit1_r,      -- one-hit case → way = hit1
	    S  => xor_hits,  -- 1 = hit case, 0 = LRU
	    Y  => mux_out
	);


	----------------------------------------------------------------
	-- Per-way selective write
	-- RD_WR = '1' => READ, RD_WR = '0' => WRITE
	--------------------------------------------------------------
	-- Inverters

	inv_fsm_rw : entity work.inverter
    	port map (
    	input  => FSM_RW_Enable,
    	output => FSM_RW_Enable_not
    	);

	inv_muxout : entity work.inverter
    	port map (
    	input  => mux_out,
    	output => mux_out_not
    	);

   	 
	-- Write select signals
    
	-- wr0_sel = (NOT FSM_RW_Enable) AND (mux_out = '0')
	wr0_and : entity work.and2
    	port map (
    	input1 => FSM_RW_Enable_not,
    	input2 => mux_out_not,
    	output => wr0_sel
    	);

	-- wr1_sel = (NOT FSM_RW_Enable) AND (mux_out = '1')
	wr1_and : entity work.and2
    	port map (
    	input1 => FSM_RW_Enable_not,
    	input2 => mux_out,
    	output => wr1_sel
    	);
   	 
   
	-- RD_WR_way0 mux
	mux_rdwr0 : entity work.mux2to1
    	port map (
    	S  => wr0_sel,
    	I0 => '1',   -- default = READ
    	I1 => '0',   -- WRITE when wr0_sel=1
    	Y  => RD_WR_way0
    	);

	-- RD_WR_way1 mux
	mux_rdwr1 : entity work.mux2to1
    	port map (
    	S  => wr1_sel,
    	I0 => '1',   -- default READ
    	I1 => '0',   -- WRITE for way1
    	Y  => RD_WR_way1
    	);

 
	----------------------------------------------------------------
	-- Write data source: CPU vs memory refill
	----------------------------------------------------------------
	Write_Data_Mux : entity work.mux2to1_8bit
    	port map (
        	S  => FSM_Mux_Sel,
        	I1 => Reg_Data_Q,  -- CPU write data
        	I0 => mem_data,	-- memory refill data
        	Y  => write_data_bus
    	);

	----------------------------------------------------------------
	-- Demux write_data_bus to selected way
	----------------------------------------------------------------
	DEMUX_Data : entity work.demux2to1_8bit
    	port map (
        	sel 	=> mux_out,
        	data_in => write_data_bus,
        	out1	=> D_in_way1,
        	out0	=> D_in_way0
    	);

	----------------------------------------------------------------
	-- CPU read mux
	----------------------------------------------------------------
	CPU_Data_Mux : entity work.mux2to1_8bit
    	port map (
        	S   => mux_out,
        	I0  => data_way0,
        	I1  => data_way1,
        	Y   => CPU_Data_Int
    	);

	----------------------------------------------------------------
	-- Tri-state driver to CPU
	----------------------------------------------------------------
	Tx_CPU_Data : entity work.tx_8bit
    	port map (
        	sel	=> FSM_CPU_Out_En,
        	selnot => not FSM_CPU_Out_En,
        	input  => CPU_Data_Int,
        	output => cpu_data
    	);

	----------------------------------------------------------------
	-- FSM Controller
	----------------------------------------------------------------
	FSM_Inst : entity work.cache_fsm_struct
    	port map (
        	clk        	=> clk,
        	reset      	=> reset,
        	start      	=> start,
        	read_write 	=> cpu_rd_wrn,
        	cvt        	=> hit_any_way,
        	busy       	=> busy_internal,
        	output_enable  => FSM_CPU_Out_En,
        	rw_enable  	=> FSM_RW_Enable,
        	mux_sel    	=> FSM_Mux_Sel,
        	decoder_enable => FSM_Decoder_Enable,
        	mem_enable 	=> FSM_Mem_Enable,
        	valid_bit  	=> FSM_Valid_Bit,
        	byte_cnt_out   => FSM_Byte_Counter,
        	latch_en   	=> FSM_Latch_En
    	);

	----------------------------------------------------------------
	-- Outputs
	----------------------------------------------------------------
	busy   <= busy_internal;
	mem_en <= FSM_Mem_Enable;
	mem_add <= Reg_Addr_Q;

end architecture;
