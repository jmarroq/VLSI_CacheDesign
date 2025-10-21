// concatenate start, CVT, RD/WR
SCRW = {start, CVT, RW;}
// our cases/states are determined from theese states
// case statement is a MUX
casex (SCRW)
    111: RD hit  
    101: RD miss
    110: WR hit
    100: WR miss
    default: idle
endcase

input operateration 
states {IDLE, READ_HIT, READ_MISS, WRITE_HIT, WRITE_MISS, RH2, RM2, DELA1, BUSY, DONE, WRITE_FOR_READ, DELAY2, DELAY3}
always_ff @( negedge clock ) begin : fsm
NS = CS
case(cs)
IDLE: begin
    // could also make a mux if concatenate start, cvt, rd/wr
    /*
    sel = {START, CVT, RD/WR}
    case (sel)
    111: RD hit  
    101: RD miss
    110: WR hit
    100: WR miss
    default: idle
    NS = output of the MUX
    */
    if (start == 0)begin
        NS = IDLE;
    end
    else if (start == 1)begin
        if(RD_WR == 1 && CVT == 1)begin
            // READ HIT
            NS = READ_HIT;
        end
        else if(RD_WR == 1 && CVT == 0)begin
            // READ HIT
            NS = READ_MISS;
        end
        else if(RD_WR == 0 && CVT == 1)begin
            // WRITE HIT
            NS = READ_MISS;
        end
        else if(RD_WR == 0 && CVT == 0)begin
            // WRITE MISS
            NS = READ_MISS;
        end
    end 
end
READ_HIT: begin
    // valid read 
    // set flags
    BUSY = 1;
    OE_CPU_D = 0;

    // read form cache block 
    // set (CE_INDEX)
    // address in decoder 
    ENABLE_DECODER_1 = 1;
    // CE_offset 
    ENABLE_DECODER_2 = 1;
    NS = RH2;
end
RH2: begin
    OE_CPU_D = 1;
    RESET_Register = 1;
    BUSY = 0;
    NS = DONE;
end 

READ_MISS: begin
    // not valid couldnt read
    BUSY = 1;
end
RM2: begin
    OE = 1;
    ME = 1;
    // send address to memory
    // set the delay counter value to 8 
    NS = DELAY1
end 

WRITE_HIT: begin
    BUSY = 1;
    // set flags to determine where writing 
    ENABLE_DECODER_1 = 1;
    ENABLE_DECODER_2 = 1;
    OE_CPU_D = 1;
    MUX_S = 1
    NS = DELAY3;
end

WRITE_MISS: begin
    BUSY = 1;
    NS = DELAY3;
end
DELAY1:begin
    // buffer?
    // need to keep track of number of delays so know when to move to NS
    // in the previous state start a (down) counter (init to max) and decrement the counter here 

    if (counter1 > 0)begin 
        // subtractor or shift register
        counter1--;
        NS = DELAY1;
    end
    // done the count
    else begin
        NS = WRITE_FOR_READ;
        // set counter2 to 4
    end

end
WRITE_FOR_READ:begin
    BUSY = 1;
    NS = DELAY2;
end

DELAY2:begin
    // buffer
    if (counter2 > 0)begin 
        // subtractor or shift register
        counter2--;
        NS = WRITE_FOR_READ;
    end
    // done the count
    else begin
        NS = DONE;
    end
end

DELAY3:begin
    // buffer
    NS = DONE;
end
DONE: begin
    // reset everything
    OE_CPU_D = 0;
    OE_MA = 0;
    BUSY = 0;

    NS = IDLE;
end
endcase

end

