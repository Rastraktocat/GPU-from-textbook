module gpu_thread(
    input logic clk,
    input logic thread_pc,
    // determine size
    input single_warp_inst inst,
    input logic [1:0] warp_num,
    
    input logic bank_ready1,
    input logic cache_ready1,
    input logic bank_ready2,
    input logic cache_ready2,

    input logic bank_input1,
    input logic cache_input1,
    input logic bank_input2,
    input logic cache_input2,
    // todo determine the size.
    
    output logic branch, 

    output logic convergence_barrier_met,
    // specify whether a thread
    // is at a convergence barrier.
    // todo fix this name
    output logic bank_writeback,
    output logic cache_writeback,
    output logic writeback_contents, 
    output logic pc_out
    // todo fix the sizes of the 
    // 4 variables above this.
);

// this module currently shows 
// thread behavior.

enum [1:0] logic {
    AT_BARRIER,
    YIELDED,
    READY
} thread_state_enum;
// size subject to change.
// Signifies whether a thread is ready to execute, 
// blocked at a convergence barrier (specify which), 
// or has yielded. 

thread_state_enum thread_state;
logic [31:0] thread_rPC_state; // the next address to run. 
// only when not running.
logic thread_active;
// active in the warp or not.

logic c_flag;
logic o_flag;
logic z_flag;
logic s_flag;

logic float_invalid; // No math defined result (0/0, sqrt -1 )
logic float_div_zero; // dividing by zero.
logic float_overflow; // too large to be represented. (1e308 * 1e308). 
logic float_underflow; // too small to be represented. (-1e308 - 1e308).
logic float_inexact; // needs to be rounded (1/3 and pi).

logic thread_writeback_contents;
// todo fix the size of this.

always_ff@( posedge clk ) begin

    if (thread_pc == ) begin 
        // todo Create a number
        // for signifying a convergence barrier.

        thread_state = AT_BARRIER;
        thread_rPC_state = thread_pc + 1;
        convergence_barrier_met = 1;
    end

    // opcode numbers
    // 1 is add | 2 is sub | 3 is mul | 4 is div
    // 5 is inc | 6 is dec | 7 is neg | 8 is abs
    // 9 is and | 10 is or | 11 is xor | 12 is not
    // 13 is shr | 14 is shl | 15 is rcl | 16 is rcr
    // 17 is cmp | 18 is test | 19 is mov | 22 is jmp 
    // 23 is jz | 24 is jnz
    // 25 is jg | 26 is jl | 27 is jo | 28 is jno | 
    // 29 is jc | 30 is jnc 
    // todo FIX THE OPCODES
    if (inst.warp_operand_size1 == inst.warp_operand_size2) begin
        case (inst.opcode)
        'd0: begin 
            thread_writeback_contents = inst.operand1 + inst.operand2;
            c_flag = thread_writeback_contents[inst.operand_size1];
            o_flag = (inst.operand1[31] == inst.operand[31]) &&
                     (thread_writeback_contents[31] != inst.operand1[31]);
            z_flag = thread_writeback_contents == 0 ? 1 : 0;
            s_flag = thread_writeback_contents[inst.warp_operand_size1];
        end
        'd1: begin
            thread_writeback_contents = inst.operand1 - inst.operand2;            
            c_flag = thread_writeback_contents[inst.operand_size1];
            o_flag = (inst.operand1[31] == inst.operand[31]) &&
                     (thread_writeback_contents[31] != inst.operand1[31]);
            z_flag = thread_writeback_contents == 0 ? 1 : 0;
            s_flag = thread_writeback_contents[inst.warp_operand_size1];
            pc_out = pc_out + 1;
        end
        'd2: begin
            thread_writeback_contents = inst.operand1 * inst.operand2;
            z_flag = thread_writeback_contents == 0 ? 1 : 0;
        end
        'd3: thread_writeback_contents = inst.operand1 / inst.operand2;
        'd4: thread_writeback_contents = inst.operand1 + 1;
        'd5: thread_writeback_contents = inst.operand1 - 1;
        'd6: thread_writeback_contents = inst.operand1 * -1; // fix this.
        'd7: thread_writeback_contents = $abs(inst.operand1);
        'd8: thread_writeback_contents = and(inst.operand1, inst.operand2);
        'd9: thread_writeback_contents = or(inst.operand1, inst.operand2);
        'd10: thread_writeback_contents = xor(inst.operand1, inst.operand2);
        'd11: thread_writeback_contents = not(inst.operand1);
        'd12: thread_writeback_contents = inst.operand1 << inst.operand2;
        'd13: thread_writeback_contents = inst.operand2 >> inst.operand2;
        'd14: // implement this.
        'd15: // implement this.
        'd16: // implement this.
        'd17: thread_writeback_contents = inst.operand2; // fix mov.
        'd18: pc_out = inst.operand1; // jmp 
        'd19: begin // jz 
            pc_out = z_flag == 1 ? inst.operand1 : thread_pc + 1; // fix this.
            thread_rPC_state = pc_out;
            branch = 1;
        end
        'd20: begin // jnz            
            thread_rPC_state = z_flag == 1 ? thread_pc + 1 : inst.operand1;
            pc_out = inst.operand1;
            branch = 1;
        end
        'd21: begin // jg
            thread_rPC_state = inst.operand1;
            pc_out = 
        end
        
        default: $fatal(1, "Invalid opcode");
        endcase 

        // todo implement all of the flags 
        // and alu commands.

        writeback_contents = thread_writeback_contents;

    end
    else begin
        $fatal(1, "Operand sizes are not the same.");
    end 
end

endmodule