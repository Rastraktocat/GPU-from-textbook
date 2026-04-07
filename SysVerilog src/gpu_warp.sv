module gpu_warp(
    input logic clk, 
    input all_warp_pc pc,
        
    input logic memory_warp_bank_in;
    input logic bank_in1,
    input logic bank_in2,

    input logic bank_request_in1,
    input logic bank_request_in2,
    // todo determine the size
    // of the input. 

    input logic memory_warp_cache_in;
    input logic cache_request_in1,
    input logic cache_request_in2,
    // TODO the size of the cache
    // has not been determined yet.

    output logic bank_out1,
    output logic bank_out2,
    output logic bank_request_out1,
    output logic bank_request_out2,
    // todo determine the size.
    output logic cache_request_out1,
    output logic cache_request_out2,
    output logic writeback
    // The banks and cache requests
    // that are correlated to the 
    // banks and cache in the parent 
    // module.

    // TODO Add the outputs that relay
    // the operands to the parent module.
    
);

// This module is currently the
// thread scheduler (warp) 

// TODO FIX THE DESCRIPTION.

typedef struct packed {
    logic [1:0] warp_operand_size1,
    logic [1:0] warp_operand_size2,
        // the operand size | made of 2 bits
        // 00 is 8 bits | 01 is 16 bits
        // 10 is 32 bits | 11 is 64 bits
    logic [1:0] warp_addressing_mode1,
    logic [1:0] warp_addressing_mode2,
        // the addressing mode made of 2
        // bit each 4 bits normally 
        // THE FIRST OPERAND CANNOT
        // BE AN IMMEDIATE.
        // 0 is immediate | 1 is register
        // 2 is memory address
    logic [4:0] warp_opcode,
        // assume for now 5 bit opcodes.
    logic [63:0] warp_operand1,
    logic [63:0] warp_operand2
        // the actual operand | 64 bits each
        // 128 bits in total
} single_warp_pc;

typedef struct {    
    // for warp 0
    logic [31:0] barrier_participation_mask_0;
    // tracks which threads participate in a
    // given convergence barrier.
    logic [31:0] barrier_state_field_0;
    // tracks which threads have arrived 
    // at a given convergence barrier.

    // for warp 1
    logic [31:0] barrier_participation_mask_1;
    logic [31:0] barrier_state_field_1;
    // for warp 2
    logic [31:0] barrier_participation_mask_2;
    logic [31:0] barrier_state_field_2;
    // for warp 3
    logic [31:0] barrier_participation_mask_3;
    logic [31:0] barrier_state_field_3;

} warp_barrier_variables;

typedef struct {
    // These variables tell
    // the warps if they are
    // waiting on instructions
    
    // banking variables.
    logic warp1_bank1;
    logic warp1_bank2;
    logic warp2_bank1;
    logic warp2_bank2;
    logic warp3_bank1;
    logic warp3_bank2;
    logic warp4_bank1;
    logic warp4_bank2;

    // cache_variables.
    logic warp1_cache1;
    logic warp1_cache2;
    logic warp2_cache1;
    logic warp2_cache2;
    logic warp3_cache1;
    logic warp3_cache2;
    logic warp4_cache1;
    logic warp4_cache2;
} warp_current_dependency_variables;

////////////////////////////////////////////////////////////

// this part of the module that handles 
// requesting memory resources
// EX. If the operands are registers
// then the warp needs to be 
// told to request memory from 
// the bank

////////////////////////////////////////////////////////////
    
bank_out1 = current_warp_pc.operand1 == 0 ? 1 : 0;
// for the first operand 0 is register
// and 1 is memory

bank_out2 = current_warp_pc.operand2 == 1 ? 1 : 0;
// for the second operand 1 is register
// and 2 is memory.

bank_request_out1 = pc.warp_operand1 [5:0];
bank_request_out2 = pc.warp_operand2 [5:0];

// bank_in and bank_request_in have 
// to happen at the same time. Even 
// if there is a warp divergence 
// ALL registers will be requested.

// todo check if the comments are proper.

cache_request_out_1 = current_warp_pc.operand1 == 1 ? 1 : 0;
// for the first operand 1 is register
// and 2 as memory

cache_request_out_2 = current_warp_pc.operand2 == 2 ? 1 : 0;

genvar thread_idx;

single_warp_pc current_warp_pc;
warp_barrier_variables wbv;
warp_current_dependency_variables wcdv;

logic [1:0] running_warp;
logic [31:0] bank_ready_buffer;
logic [31:0] cache_ready_buffer;
logic [31:0] bank_writeback_buffer;
logic [31:0] cache_writeback_buffer;
logic [2047:0] writeback_buffer; 

generate begin
    for (thread_idx = 0; thread_idx < 32; thread_idx = thread_idx + 1) begin
        gpu_thread gt(
            .clk(clk),
            .pc(current_warp_pc),
            .bank_ready(bank_ready_buffer),
            .cache_ready(cache_ready_buffer),
            .convergence_yielded(),
            .bank_writeback(bank_writeback_buffer[thread_idx]),
            .cache_writeback(cache_writeback_buffer[thread_idx]),
            .writeback_contents(writeback_buffer[thread_idx*32+31:thread_idx*32])
        );
        // todo make sure the ports
        // align properly.
    end
endgenerate

////////////////////////////////////////////////////////////

// This is a warp scheduler.

////////////////////////////////////////////////////////////

always_ff@( posedge clk ) begin
    if ( (wcdv.warp1_bank1 and wcdv.warp1_cache1) &&
         (wcdv.warp1_bank2 and wcdv.warp1_cache2) ) begin
        running_warp = 0;
        current_warp_pc = pc.warp1_pc;
    end 
    else if ((wcdv.warp2_bank1 and wcdv.warp2_cache1) &&
            (wcdv.warp2_bank2 and wcdv.warp2_cache2)) begin
        running_warp = 1;
        current_warp_pc = pc.warp2_pc;
    end
    else if ((wcdv.warp3_bank1 and wcdv.warp3_cache1) && 
            (wcdv.warp3_bank2 and wcdv.warp3_cach2)) begin
        running_warp = 2;
        current_warp_pc = pc.warp3_pc;
        
    end
    else if ((wcdv.warp4_bank1 and wcdv.warp4_cache1) && 
            (wcdv.warp4_bank2 and wcdv.warp4_cache2)) begin
        running_warp = 3;
        current_warp_pc = pc.warp4_pc;
    end 
    else begin
        // make this a yield.
    end
    // todo make the threads have valid 
    // ports so that these can be completed.


end

endmodule