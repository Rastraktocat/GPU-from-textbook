module gpu_thread(
    input logic clk,
    input single_warp_pc pc,
    
    input logic bank_ready1,
    input logic cache_ready1,
    input logic bank_ready2,
    input logic cache_ready2,

    input logic bank_input1,
    input logic cache_input1,
    input logic bank_input2,
    input logic cache_input2,
    // todo determine the size.
    
    output logic convergence_yielded,
    // specify whether a thread
    // is at a convergence barrier.
    // todo fix this name
    output logic bank_writeback,
    output logic cache_writeback
    output logic writeback_contents
    // todo fix the sizes of the 
    // 3 variables above this.
);

// this module currently shows 
// thread behavior.

logic [31:0] thread_state; // size subject to change.
// Signifies whether a thread is ready to execute, 
// blocked at a convergence barrier (specify which), 
// or has yielded. 
logic [31:0] thread_rPC_state; // the next address to run. 
// only when not running.
logic thread_active;
// active in the warp or not.

always_ff@( posedge clk ) begin
    // opcode numbers
    // 1 is add | 2 is sub | 3 is mul | 4 is div
    // 5 is inc | 6 is dec | 7 is neg | 8 is abs
    // 9 is and | 10 is or | 11 is xor | 12 is not
    // 13 is shr | 14 is shl | 15 is rcl | 16 is rcr
    // 17 is cmp | 18 is test | 19 is mov | 20 is push
    // 21 is pop | 22 is jmp | 23 is jz | 24 is jnz
    // 25 is jg | 26 is jl | 27 is jo | 28 is jno | 
    // 29 is jc | 30 is jnc | 31 is call | 32 is ret
    if () begin
        case (pc.opcode) begin
        'd1: 
        endcase 
    end
end

endmodule