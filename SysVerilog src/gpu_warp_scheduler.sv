import gpu_structs::*;
module gpu_warp_scheduler #(
    parameter PC_BIT_SIZE = 16

)  (
    input logic clk,

    input logic write_warp_num,

    input logic jmp_pc_in,
    input all_warp_pc_t pc,
    input logic pc_in,
    // todo determine if this is necessary 
    // with the existing 
    output logic running_warp,
    output single_warp_inst_t inst_out,
    output logic pc_out
    // todo determine size.
);

    /////////////////////////////

    // This module is a warp scheduler

    /////////////////////////////
    
    logic readily_available_warp_pc;
    logic readily_available_warp_num;
    // todo change the size of this.
    // make

    logic warp_jump_array;
    // todo change the size of the 
    // jump queue.

    warp_scheduling_status_t wss;

    initial begin
        if (pc.pc0 == ) begin
            wss.warp0_status = WARP_DONE;
        end
        // todo this is checking if
        // the pc for warp 0 is preset
        // to the eof keyword. Determine
        // the eof keyword for all warps.
        else begin
            wss.warp0_status = WARP_READY;
        end
        if (pc.pc1 == ) begin
            wss.warp1_status = WARP_DONE;
        end else begin  
            wss.warp1_status = WARP_READY;
        end // this is for warp 1
        if (pc.pc2 == ) begin
            wss.warp2_status = WARP_DONE;
        end else begin
            wss.warp2_status = WARP_READY;
        end
        if (pc.pc3 == ) begin
            wss.warp3_status = WARP_DONE;
        end else begin
            wss.warp3_status = WARP_READY;
        end
    end

    always_ff@( posedge clk ) begin

        readily_available_warp_pc = wss.warp0_status == WARP_READY ? pc.warp0_pc : 
                                    wss.warp1_status == WARP_READY ? pc.warp1_pc : 
                                    wss.warp2_status == WARP_READY ? pc.warp2_pc : 
                                    wss.warp3_status == WARP_READY ? pc.warp3_pc : 0;
        // todo change the if all warps fail character.
        readily_available_warp_num = wss.warp0_status == WARP_READY ? 0 : 
                                     wss.warp1_status == WARP_READY ? 1 : 
                                     wss.warp2_status == WARP_READY ? 2 : 
                                     wss.warp3_status == WARP_READY ? 3 : 4;

        if (jmp_pc_in != 4) begin 
            // 4 means no jump by any warp.

            // if one of the warps performed a
            // jump then this will be the 
            // mechanism that assigns it.

            warp_jump_array[*jmp_pc_in] = pc_in;
            // todo find out the size of 
            // jump address.
        end

        // todo fix any pc's that could possibly be 
        // assigned a new input but not get 
        case ( readily_available_warp_num )
            'd0: begin
                if (pc_in == ) begin 
                    // todo determine an eof
                    wss.warp0_status = DONE;
                    // todo make this do an instruction 
                    // replay.
                end        
                else begin
                    pc_out = warp_jump_array == 'hFFF? pc.warp1_pc + 1 : warp_jump_array[*jmp_pc_in]; 
                                                
                    // todo check if 1 is good enough to
                    // add to the pc and add in the placeholder
                    // numbers for jmp_pc_in and 'hFFF.
                    inst_out = [pc_out*166+165:pc_out*166] mem;
                    // todo make sure that the write instruction
                    // gets output
                end 
            end
            'd1: begin
                inst.warp2_inst = 
                pc_in = pc.warp2_pc;
            end
            'd2: begin
                inst.warp2_inst = 
                pc_in = pc.warp3_pc;
            end
            'd3: begin
                inst.warp3_inst =
                pc_in = pc.warp4_pc;
            end
            default : begin
                $fatal(1, "Check the gpu_warp_scheduler.sv");
            end
        endcase

    running_warp = readily_available_warp_num;
    // todo this is the warp that
    // is currently running.

    end // always
endmodule 