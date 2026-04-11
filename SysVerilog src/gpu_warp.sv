module gpu_warp(
    input logic clk, 
    input all_warp_pc warp_pc,
    input all_warp_inst warp_inst,
        
    input logic bank_warp_read1,
    input logic bank_warp_read2,
    input logic bank_warp_write1,
    input logic bank_warp_write2,
    
    input logic memory_warp_bank_in;

    input logic bank_request_in1,
    input logic bank_request_in2,
    // todo determine the size
    // of the input. 

    input logic warp_write_complete,
    input logic [1:0] warp_write_complete_number,

    input logic cache_warp_read,
    input logic cache_warp_write,

    input logic memory_warp_cache_in,
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
    output logic writeback,
    output logic warp_pc_out
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
} single_warp_inst;

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
    logic [31:0] warp0_branch_queue [$:5];
    logic [31:0] warp1_branch_queue [$:5];
    logic [31:0] warp2_branch_queue [$:5];
    logic [31:0] warp3_branch_queue [$:5];
} warp_branch_queue_variables;

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

    // bank write variables.
    logic warp1_bank_write;
    logic warp2_bank_write;
    logic warp3_bank_write;
    logic warp4_bank_write;

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

single_warp_inst current_warp_inst;
warp_barrier_variables wbv;
warp_branch_queue_variables wbqv;
warp_current_dependency_variables wcdv;

logic [1:0] running_warp;
logic [31:0] thread_bank_ready_buffer;
logic [31:0] thread_cache_ready_buffer;
logic [31:0] thread_bank_writeback_buffer;
logic [31:0] thread_cache_writeback_buffer;
logic [2047:0] writeback_buffer; 

logic warp_all_threads_converged;
logic warp_switch_threads_running;
logic [31:0] barrier_variable;
logic [31:0] warp_branch;
logic [31:0] warp_convergence_yielded;
logic jmp_pc;
// todo fix size.
logic warp_divergence_pc_store;

generate begin
    for (thread_idx = 0; thread_idx < 32; thread_idx = thread_idx + 1) begin
        gpu_thread gt(
            .clk(clk),
            .thread_pc(warp_pc),
            .inst(current_warp_inst),
            .bank_ready(bank_ready_buffer),
            .cache_ready(cache_ready_buffer),
            .branch(warp_branch[i]),
            .convergence_yielded(warp_convergence_yielded[i]),
            .bank_writeback(bank_writeback_buffer[thread_idx]),
            .cache_writeback(cache_writeback_buffer[thread_idx]),
            .writeback_contents(writeback_buffer[thread_idx*32+31:thread_idx*32]),
            .pc_out(jmp_pc)
        );
        // todo Make jmp_pc request the said
        // pc address.
    end
endgenerate

////////////////////////////////////////////////////////////

// This is a warp scheduler.

////////////////////////////////////////////////////////////

always_ff@( posedge clk ) begin

    if (warp_write_complete) begin
        if (warp_write_complete_number == 0) begin
            wcdv.warp1_bank_write = 1;
        end
        if (warp_write_complete_number == 1) begin 
            wcdv.warp2_bank_write = 1;
        end
        if (warp_write_complete_number == 2) begin
            wcdv.warp3_bank_write = 1;
        end 
        if (warp_write_complete_number == 3) begin
            wcdv.warp4_bank_write = 1;
        end
    end

    if ( (wcdv.warp1_bank1 && wcdv.warp1_cache1 && wcdv.warp1_bank_write) &&
         (wcdv.warp1_bank2 and wcdv.warp1_cache2) ) begin
        running_warp = 0;
        current_warp_inst = pc.warp1_inst;
    end 
    else if ((wcdv.warp2_bank1 && wcdv.warp2_cache1 && wcdv.warp2_bank_write) &&
            (wcdv.warp2_bank2 and wcdv.warp2_cache2)) begin
        running_warp = 1;
        current_warp_inst = pc.warp2_inst;
    end
    else if ((wcdv.warp3_bank1 and wcdv.warp3_cache1 && wcdv.warp3_bank_write) && 
            (wcdv.warp3_bank2 and wcdv.warp3_cach2)) begin
        running_warp = 2;
        current_warp_inst = pc.warp3_inst;
    end
    else if ((wcdv.warp4_bank1 and wcdv.warp4_cache1 && wcdv.warp4_bank_write) && 
            (wcdv.warp4_bank2 and wcdv.warp4_cache2)) begin
        running_warp = 3;
        current_warp_inst = pc.warp4_pc;
    end

    // todo make the threads have valid 
    // ports so that these can be completed.

    if (branch != 'hFF) begin
        case (running_warp) 
        'd0: begin 
            wbv.barrier_participation_mask_0 = branch;
            wbqv.warp0_branch_queue.push_front(pc_in);
        end
        'd1: begin
            wbv.barrier_participation_mask_1 = branch;
            wbqv.warp1_branch_queue.push_front(pc_in);
        end
        'd2: begin
            wbv.barrier_participation_mask_2 = branch;
            wbqv.warp2_branch_queue.push_front(pc_in);
        end
        'd3: begin 
            wbv.barrier_participation_mask_3 = branch; 
            wbqv.warp3_branch_queue.push_front(pc_in);
        end
        endcase
    end

    case (running_warp) 
        'd0: begin 
            warp_switch_threads_running = 
            wbv.warp_barrier_participation_mask_0 == wbv.barrier_state_field_0 ? 0 : 1;
            warp_all_threads_converged = wbv.warp_state_field0 == 'hFF ? 0 : 1;
        end
        'd1: begin 
            warp_switch_threads_running = 
            wbv.warp_barrier_participation_mask_1 == wbv.barrier_state_field_1 ? 0 : 1;
            warp_all_threads_converged = wbv.warp_state_field1 == 'hFF ? 0 : 1;
        end
        'd2: begin 
            warp_switch_threads_running = 
            wbv.warp_barrier_participation_mask_2 == wbv.barrier_state_field_2 ? 0 : 1;
            warp_all_threads_converged = wbv.warp_state_field2 == 'hFF ? 0 : 1;
        end
        'd3: begin 
            warp_switch_threads_running = 
            wbv.warp_barrier_participation_mask_3 == wbv.barrier_state_field_3 ? 0 : 1;
            warp_all_threads_converged = wbv.warp_state_field3 == 'hFF ? 0 : 1;
        end
    endcase
    // todo fix this.    

    if (warp_switch_threads_running) begin
        warp_pc_out = warp_divergence_pc_store;
    end else begin
        warp_pc_out = pc_in + 1;
    end

    if (warp_all_threads_converged) begin
        case (running_warp) 
            'd0: begin
                wbqv.warp0_branch_queue.pop_back();
            end
            'd1: begin
                wbqv.warp1_branch_queue.pop_back();
            end
            'd2: begin
                wbqv.warp2_branch_queue.pop_back();
            end
            'd3: begin
                wbqv.warp3_branch_queue.pop_back();
            end
        endcase
    end

end
endmodule