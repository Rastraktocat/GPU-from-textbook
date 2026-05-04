module gpu_thread(
    input logic clk,
    input logic thread_pc,
    // determine size
    input single_warp_inst_t inst,
    input logic [1:0] warp_num,
    
    input logic bank_ready1,
    input logic cache_ready1,
    input logic bank_ready2,
    input logic cache_ready2,

    input logic [63:0] bank_input1,
    input logic [63:0] cache_input1,
    input logic [63:0] bank_input2,
    input logic [63:0] cache_input2,
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

    import gpu_structs::*;
// this module currently shows 
// thread behavior.
// TODO CHECK ALL OF THE BEHAVIOR

thread_state_enum_t thread_state;
logic [31:0] thread_rPC_state; // the next address to run. 
// only when not running.
// todo make a parameter for pc size.
logic thread_active;
// active in the warp or not.

logic c_flag;
logic o_flag;
logic z_flag;
logic s_flag;

logic [63:0] thread_writeback_contents;

logic [64:0] ext_a, ext_b, ext_res;
logic [64:0] rot;
int sh;
logic [63:0] tmp;

always_ff@( posedge clk ) begin
    // TODO replace all of the inst.operand with
    // the cache and bank input values.

    if (thread_pc == ) begin 
        // todo Create a number
        // for signifying a convergence barrier.

        thread_state = AT_BARRIER;
        thread_rPC_state = thread_pc + 1;
        convergence_barrier_met = 1;
    end
    // todo fix this.

    // opcode numbers
    // 1 is add | 2 is sub | 3 is mul | 4 is div
    // 5 is inc | 6 is dec | 7 is neg | 8 is abs
    // 9 is and | 10 is or | 11 is xor | 12 is not
    // 13 is shr | 14 is shl | 15 is rcl | 16 is rcr
    // 17 is cmp | 18 is test | 19 is mov | 20 is jmp 
    // 21 is jz | 22 is jnz | 23 is jg | 24 is jl |
    // 25 is jo | 26 is jno | 27 is jc | 28 is jnc 
    // todo recheck the opcodes.

    // Extended 65‑bit values for carry/overflow detection
    if (bank_ready1) begin
        ext_a = {1'b0, bank_input1};
    end
    else if (cache_ready1) begin
        ext_a = {1'b0, cache_input1};
    end
    else if (bank_ready2) begin
        ext_b = {1'b0, bank_input2};
    end
    else if (cache_ready2) begin
        ext_b = {1'b0, cache_input2};
    end

    case (inst.opcode)
        // ============================================================
        //  ADD (64‑bit)
        // ============================================================
        'd0: begin
            ext_res = ext_a + ext_b;
            thread_writeback_contents <= ext_res[63:0];

            c_flag <= ext_res[64];  // carry out
            o_flag <= (inst.operand1[63] == inst.operand2[63]) &&
                      (thread_writeback_contents[63] != inst.operand1[63]);
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
        end

        // ============================================================
        //  SUB (64‑bit)
        // ============================================================
        'd1: begin
            ext_res = ext_a - ext_b;
            thread_writeback_contents <= ext_res[63:0];

            c_flag <= ext_res[64];  // borrow
            o_flag <= (inst.operand1[63] != inst.operand2[63]) &&
                      (thread_writeback_contents[63] != inst.operand1[63]);
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
        end

        // ============================================================
        //  MUL (64‑bit, low 64 bits only)
        // ============================================================
        'd2: begin
            thread_writeback_contents <= inst.operand1 * inst.operand2;
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            c_flag <= 1'b0;
            o_flag <= 1'b0;
        end

        // ============================================================
        //  DIV (64‑bit)
        // ============================================================
        'd3: begin
            thread_writeback_contents <= inst.operand1 / inst.operand2;
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
        end

        // ============================================================
        //  INC (64‑bit)
        // ============================================================
        'd4: begin
            ext_res = ext_a + 65'd1;
            thread_writeback_contents <= ext_res[63:0];

            c_flag <= ext_res[64];
            o_flag <= (inst.operand1[63] == 1'b0) &&
                      (thread_writeback_contents[63] == 1'b1);
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
        end

        // ============================================================
        //  DEC (64‑bit)
        // ============================================================
        'd5: begin
            ext_res = ext_a - 65'd1;
            thread_writeback_contents <= ext_res[63:0];

            c_flag <= ext_res[64];
            o_flag <= (inst.operand1[63] == 1'b1) &&
                      (thread_writeback_contents[63] == 1'b0);
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
        end

        // ============================================================
        //  NEG (two’s complement)
        // ============================================================
        'd6: begin
            thread_writeback_contents <= (~inst.operand1) + 64'd1;

            c_flag <= (inst.operand1 != 64'd0);
            o_flag <= (inst.operand1 == 64'h8000_0000_0000_0000);
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
        end

        // ============================================================
        //  ABS (64‑bit)
        // ============================================================
        'd7: begin
            if (inst.operand1[63])
                thread_writeback_contents <= (~inst.operand1) + 64'd1;
            else
                thread_writeback_contents <= inst.operand1;

            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            c_flag <= 1'b0;
            o_flag <= 1'b0;
        end

        // ============================================================
        //  AND / OR / XOR / NOT
        // ============================================================
        'd8:  thread_writeback_contents <= inst.operand1 & inst.operand2;
        'd9:  thread_writeback_contents <= inst.operand1 | inst.operand2;
        'd10: thread_writeback_contents <= inst.operand1 ^ inst.operand2;
        'd11: thread_writeback_contents <= ~inst.operand1;

        // Flag updates for logical ops
        'd8, 'd9, 'd10, 'd11: begin
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            c_flag <= 1'b0;
            o_flag <= 1'b0;
        end

        // ============================================================
        //  SHL / SHR (logical)
        // ============================================================
        'd12: begin // SHL
            thread_writeback_contents <= inst.operand1 << inst.operand2[5:0];
            c_flag <= (inst.operand2 == 0) ? c_flag :
                      inst.operand1[64 - inst.operand2];
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            o_flag <= 1'b0;
        end

        'd13: begin // SHR
            thread_writeback_contents <= inst.operand1 >> inst.operand2[5:0];
            c_flag <= (inst.operand2 == 0) ? c_flag :
                      inst.operand1[inst.operand2 - 1];
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            o_flag <= 1'b0;
        end

   // ============================================================
        //  RCL / RCR (rotate through carry, 65‑bit)
        // ============================================================
        'd14: begin // RCL
            rot = {c_flag, inst.operand1};
            sh = inst.operand2[5:0] % 65;
            rot = (rot << sh) | (rot >> (65 - sh));

            c_flag <= rot[64];
            thread_writeback_contents <= rot[63:0];
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            o_flag <= 1'b0;
        end

        'd15: begin // RCR
            rot = {c_flag, inst.operand1};
            sh = inst.operand2[5:0] % 65;
            rot = (rot >> sh) | (rot << (65 - sh));

            c_flag <= rot[0];
            thread_writeback_contents <= rot[63:0];
            z_flag <= (thread_writeback_contents == 64'd0);
            s_flag <= thread_writeback_contents[63];
            o_flag <= 1'b0;
        end

        // ============================================================
        //  CMP (no writeback)
        // ============================================================
        'd16: begin
            ext_res = ext_a - ext_b;

            c_flag <= ext_res[64];
            o_flag <= (inst.operand1[63] != inst.operand2[63]) &&
                      (ext_res[63] != inst.operand1[63]);
            z_flag <= (ext_res[63:0] == 64'd0);
            s_flag <= ext_res[63];
        end

        // ============================================================
        //  TEST (AND, no writeback)
        // ============================================================
        'd17: begin
            tmp = inst.operand1 & inst.operand2;

            z_flag <= (tmp == 64'd0);
            s_flag <= tmp[63];
            c_flag <= 1'b0;
            o_flag <= 1'b0;
        end

        // ============================================================
        //  MOV
        // ============================================================
        'd18: begin
            thread_writeback_contents <= inst.operand2;
            // MOV does not modify flags
        end

|   // 20 is jmp 
    // 21 is jz | 22 is jnz | 23 is jg | 24 is jl |
    // 25 is jo | 26 is jno | 27 is jc | 28 is jnc 

        // ============================================================
        //  JMP
        // ============================================================
        'd19: begin
            thread_rPC_state = inst.operand1 + 1;
            pc_out = inst.operand1;
        end
        // ============================================================
        //  JZ
        // ============================================================
        'd20: begin
            if (z_flag == 1) begin // if the z flag is on. 
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
                branch = 1;
            end
            else begin
                thread_active = 0;
                branch = 0;
                thread_rPC_state = thread_pc + 1;
                pc_out = thread_pc + 1;
            end
        end
        // ============================================================
        //  JNZ
        // ============================================================
        'd21: begin
            if (z_flag == 0) begin // if the z flag is off. 
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end
        // ============================================================
        //  JG
        // ============================================================
        'd22: begin
            if (z_flag == 0 && s_flag == 0) begin // if the z and s flags are off. 
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end
        // ============================================================
        //  JL
        // ============================================================
        'd23: begin
            if (s_flag == 1) begin // if the s flags are on 
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end        
        // ============================================================
        //  JO
        // ============================================================
        'd24: begin
            if (o_flag == 1) begin // if the o flag is on. 
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end
        // ============================================================
        //  JNO
        // ============================================================
        'd24: begin
            if (o_flag == 0) begin // if the o flag is off
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end
        // ============================================================
        //  JC
        // ============================================================
        'd24: begin
            if (c_flag == 1) begin // if the c flag is on. 
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end
        // ============================================================
        //  JNC
        // ============================================================
        'd24: begin
            if (c_flag == 0) begin // if the c flag is off
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1;
            end
            else begin
                thread_rPC_state = inst.operand1 + 1;
                pc_out = inst.operand1 + 1;
            end
        end

        default: $fatal(1, "Invalid opcode");
    endcase

    if (inst.addressing_mode1 == 1) begin // banking
        bank_writeback = 1;
        writeback_contents <= thread_writeback_contents;
    end else begin // caching
        cache_writeback = 1;
        writeback_contents <= thread_writeback_contents;
    end
end

endmodule