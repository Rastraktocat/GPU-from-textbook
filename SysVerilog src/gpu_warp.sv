module gpu_warp #(


    parameter THREADS_PER_WARP = 32,

    parameter BRANCH_QUEUE_SIZE = 6
    // this is a value to determine 
    // how many times a warp can branch
    // and store each branch mask.

    ) (
    input logic clk, 
    input all_warp_pc_t warp_pc,
    input all_warp_inst_t warp_inst,
        
    input logic bank_warp_read1,
    input logic bank_warp_read2,
    input logic bank_warp_write1,
    input logic bank_warp_write2,

    input logic [63:0] bank_request_in1,
    input logic [63:0] bank_request_in2,
    // todo determine the size
    // of the input. 

    input logic warp_write_complete,
    input logic [1:0] warp_write_complete_number,

    input logic cache_warp_read1,
    input logic cache_warp_write1,
    input logic cache_warp_read2,
    input logic cache_warp_write2,

    output logic cache_request_in1,
    output logic cache_request_in2,
    // TODO the size of the cache
    // has not been determined yet.

    output logic bank_out1,
    output logic bank_out2,
    output logic bank_request_out1,
    output logic bank_request_out2, 
    // todo determine the size 
    // of requested outs.

    output logic cache_warp_out1,
    output logic cache_warp_out2,
    output logic cache_request_out1,
    output logic cache_request_out2,
    // todo determine the size of 
    // the cache requested out.

    output logic [2047:0] writeback_buffer,
    output logic warp_pc_out
    // The banks and cache requests
    // that are correlated to the 
    // banks and cache in the parent 
    // module.

    // TODO Add the outputs that relay
    // the operands to the parent module.
    
);

    import gpu_structs::*;
// This module is currently the
// thread scheduler (warp) 

// TODO FIX THE DESCRIPTION.

// structure instantiation for use in the module.

typedef struct packed {    
    // for warp 0
    logic [THREADS_PER_WARP-1:0] barrier_participation_mask_0;
    // tracks which threads participate in a
    // given convergence barrier.
    logic [THREADS_PER_WARP-1:0] barrier_state_field_0;
    // tracks which threads have arrived 
    // at a given convergence barrier.

    // for warp 1
    logic [THREADS_PER_WARP-1:0] barrier_participation_mask_1;
    logic [THREADS_PER_WARP-1:0] barrier_state_field_1;
    // for warp 2
    logic [THREADS_PER_WARP-1:0] barrier_participation_mask_2;
    logic [THREADS_PER_WARP-1:0] barrier_state_field_2;
    // for warp 3
    logic [THREADS_PER_WARP-1:0] barrier_participation_mask_3;
    logic [THREADS_PER_WARP-1:0] barrier_state_field_3;

} warp_barrier_variables_t;

typedef struct {
    logic [THREADS_PER_WARP-1:0] warp0_branch_queue [$:BRANCH_QUEUE_SIZE-1];
    logic [THREADS_PER_WARP-1:0] warp1_branch_queue [$:BRANCH_QUEUE_SIZE-1];
    logic [THREADS_PER_WARP-1:0] warp2_branch_queue [$:BRANCH_QUEUE_SIZE-1];
    logic [THREADS_PER_WARP-1:0] warp3_branch_queue [$:BRANCH_QUEUE_SIZE-1];
} warp_branch_queue_variables_t;

typedef struct packed{
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

} warp_current_dependency_variables_t;
 
////////////////////////////////////////////////////////////

// this part of the module that handles 
// requesting memory resources
// EX. If the operands are registers
// then the warp needs to be 
// told to request memory from 
// the bank

////////////////////////////////////////////////////////////
    
genvar thread_idx;

single_warp_inst_t current_warp_inst;
warp_barrier_variables_t wbv;
warp_branch_queue_variables_t wbqv;
warp_current_dependency_variables_t wcdv;

logic [1:0] running_warp;
logic [THREADS_PER_WARP-1:0] bank_ready_buffer;
logic [THREADS_PER_WARP-1:0] cache_ready_buffer;
logic [THREADS_PER_WARP-1:0] bank_writeback_buffer;
logic [THREADS_PER_WARP-1:0] cache_writeback_buffer;

logic warp_all_threads_converged;
logic warp_switch_threads_running;
logic [THREADS_PER_WARP-1:0] barrier_variable;
logic [THREADS_PER_WARP-1:0] warp_branch;
logic [THREADS_PER_WARP-1:0] warp_convergence_yielded;
logic jmp_pc;
// todo fix size.
logic warp_divergence_pc_store;

generate
    for (thread_idx = 0; thread_idx < THREADS_PER_WARP; thread_idx = thread_idx + 1) begin
        gpu_thread gt(
            .clk(clk),
            .thread_pc(warp_pc),
            .inst(current_warp_inst),
            .warp_num(running_warp),

            .bank_ready1(),
            .cache_ready1(),
            .bank_ready2(),
            .cache_ready2(),
            .bank_input1(),
            .cache_input1(),
            .bank_input2(),
            .cache_input2(),
            // todo fix this.
            .branch(warp_branch[thread_idx]),

            .convergence_barrier_met(warp_convergence_yielded[thread_idx]),
            // todo fix this

            .bank_writeback(bank_writeback_buffer[thread_idx]),
            .cache_writeback(cache_writeback_buffer[thread_idx]),
            .writeback_contents(writeback_buffer[thread_idx*32+:31]),
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
    bank_out1 = current_warp_inst.operand1 == 0 ? 1 : 0;
    // for the first operand 0 is register
    // and 1 is memory

    bank_out2 = current_warp_inst.operand2 == 1 ? 1 : 0;
    // for the second operand 1 is register
    // and 2 is memory.

    bank_request_out1 = inst.warp_operand1 [5:0];
    bank_request_out2 = inst.warp_operand2 [5:0];

    // bank_in and bank_request_in have 
    // to happen at the same time. Even 
    // if there is a warp divergence 
    // ALL registers will be requested.

    // todo check if the comments are proper.

    cache_warp_out_1 = current_warp_pc.operand1 == 1 ? 1 : 0;
    // for the first operand 1 is register
    // and 2 as memory

    cache_warp_out_2 = current_warp_pc.operand2 == 2 ? 1 : 0;

    cache_request_out1 = 0; // todo actually implement
    cache_request_out2 = 0; // todo actuall implement

    if (warp_write_complete) begin
        case (warp_write_complete_number)
            'b00: wcdv.warp1_bank_write = 1;
            'b01: wcdv.warp2_bank_write = 1;
            'b10: wcdv.warp3_bank_write = 1;
            'b11: wcdv.warp4_bank_write = 1;
            default: $fatal(1, "warp_write_complete_number gave a number that can't happen.");
        endcase
    end

    if ( (wcdv.warp1_bank1 && wcdv.warp1_cache1 && wcdv.warp1_bank_write) && (wcdv.warp1_bank2 && wcdv.warp1_cache2) ) begin
        running_warp = 0;
        current_warp_inst = pc.warp1_inst;
    end 
    else if ((wcdv.warp2_bank1 && wcdv.warp2_cache1 && wcdv.warp2_bank_write) && (wcdv.warp2_bank2 && wcdv.warp2_cache2)) begin
        running_warp = 1;
        current_warp_inst = pc.warp2_inst;
    end
    else if ((wcdv.warp3_bank1 && wcdv.warp3_cache1 && wcdv.warp3_bank_write) && (wcdv.warp3_bank2 && wcdv.warp3_cach2)) begin
        running_warp = 2;
        current_warp_inst = pc.warp3_inst;
    end
    else if ((wcdv.warp4_bank1 && wcdv.warp4_cache1 && wcdv.warp4_bank_write) && (wcdv.warp4_bank2 && wcdv.warp4_cache2)) begin
        running_warp = 3;
        current_warp_inst = pc.warp4_pc;
    end

    // todo make the threads have valid 
    // ports so that these can be completed.

    if (warp_branch != 'hFF) begin
        // all branches that are set high are the 
        // branches that are going to be 
        case (running_warp) 
        'd0: begin 
            wbv.barrier_participation_mask_0 = warp_branch;
            wbqv.warp0_branch_queue.push_front(pc_in);
        end
        'd1: begin
            wbv.barrier_participation_mask_1 = warp_branch;
            wbqv.warp1_branch_queue.push_front(pc_in);
        end
        'd2: begin
            wbv.barrier_participation_mask_2 = warp_branch;
            wbqv.warp2_branch_queue.push_front(pc_in);
        end
        'd3: begin 
            wbv.barrier_participation_mask_3 = warp_branch; 
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