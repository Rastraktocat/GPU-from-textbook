module gpu (
    input logic clk,
    input logic rst,
    input logic inst,
    output logic out
);

    /////////////////////////////

    // This module is currently 
    // to be made into a warp
    // scheduler 

    /////////////////////////////

    initial begin
        // instructions. Size - 2+4+32+128

        // fopen is for debugging
        // readmemh is for sysverilog
        $readmemh("instruction.txt", mem);
    end

    typedef struct packed{
        single_warp_inst warp1_inst,
        single_warp_inst warp2_inst,
        single_warp_inst warp3_inst,
        single_warp_inst warp4_inst
    } all_warp_inst;

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

    typedef struct packed {
        logic warp1_pc,
        logic warp2_pc,
        logic warp3_pc,
        logic warp4_pc
    } all_warp_pc;
    // todo determine the size of these.

    typedef struct packed {
        warp_scheduling_enum [1:0] warp0_status,
        warp_scheduling_enum [1:0] warp1_status,
        warp_scheduling_enum [1:0] warp2_status,
        warp_scheduling_enum [1:0] warp3_status
    } warp_scheduling_status;

    typedef enum {
        READY,
        WAITING,
        DONE
    } warp_scheduling_enum;

    logic mem;
    all_warp_inst inst;
    // this is the instruction
    // that will be passed in.
    all_warp_pc pc;
    warp_scheduling_status wss;

    logic pc_in;
    logic pc_out
    logic [1:0] current_running_warp;

    logic bank_warp_request1;
    logic bank_warp_request2;
    logic cache_warp_request1;
    logic cache_warp_request2;
    // all of the cache and
    // bank requests are all
    // only to suggest that
    // one of the warps requests
    // information.

    logic bank_warp_request_num1;
    logic bank_warp_request_num2;
    logic cache_memory_request_1;
    logic cache_memory_request_2;
    // If the bank or cache is 
    // requested this is the 
    // memory location or register
    // that is to be requested. 

    // these are for the warp 
    // input ports.
    // TODO determine the size.

    logic warp_read1;
    logic warp_read2;
    logic warp_write1;
    logic warp_write2;

    logic bank_read1;
    logic bank_read2;
    logic bank_write1;
    logic bank_write2;

    logic bank_reg_number1;
    logic bank_reg_number2;
    // todo determine the 
    // reg number sizes.

    // these are for the banks
    // input ports.

    logic bank_register_request_output;
    // this is the output when the 
    // bank has finished getting 
    // the input.

    logic [1:0] complete_warp_num;
    logic write_complete;
    logic threads_satisfied;

    /////////////////////////////////////////

    // These are the module instantiations.

    /////////////////////////////////////////

    gpu_bank gb( 
        .clk(clk), 
        .warp_num(current_runing_warp),
        .read1(bank_read1),
        .read2(bank_read2),
        .write1(bank_write1),
        .write2(bank_write2),
        .in_reg_num1(bank_reg_number1),
        .in_reg_num2(bank_reg_number2),
        .completed_request_warp_num(complete_warp_num),
        .bank_threads_satisfied(threads_satisfied),
        .bank_write_complete(write_complete),
        
        // todo finish output
        // ports.
        );

    gpu_warp gw (
        .clk(clk),
        .warp_pc(pc_in),
        .warp_inst(inst),
        .bank_warp_read1(warp_read1),
        .bank_warp_read2(warp_read2),
        .bank_warp_write1(warp_write1),
        .bank_warp_write2(warp_write2),
        .bank_request_in1(bank_warp_num1),
        .bank_request_in2(bank_warp_num2),
        .warp_write_complete(write_complete),
        .warp_write_complete_number(complete_warp_num),
        .warp_pc(pc_out)
        // todo finish adding all of the ports.

    );

    initial begin
        wss.warp0_status = READY;
        wss.warp1_status = READY;
        wss.warp2_status = READY;
        wss.warp3_status = READY;
    end

    always_ff@( posedge clk and rst) begin

        ////////////////////////////////////

        // todo Determine and Implement the 
        // operand collector for bank requests.
        
        ////////////////////////////////////

        bank_read1 = 0;
        bank_read2 = 0;
        bank_write1 = 0;
        bank_write2 = 0;
        bank_in1 = 0;
        bank_in2 = 0;
        bank_reg_number1 = 0;
        bank_reg_number2 = 0;
        pc_in = 0;

        case ( current_running_warp )
            'd0: begin
                if (pc_out == ) begin 
                    // todo determine 
                    // an eof
                    wss.warp0_status = DONE;
                end else begin
                    pc.warp1_pc = pc_out;
                    inst.warp1_inst = [pc_out*166+165:pc_out*166] mem 
                    pc_in = pc.warp1_pc;
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
            default : 
                $fatal(1, "Check the gpu.sv");
        endcase

        if (bank_warp_request1) begin
            // todo for now ignore the
            // documentation below.

            // make the operand collector
            // first then have it pass
            // the variable into the 
            // bank module.
            bank_read1 = warp_read1;
            bank_write1 = warp_write1;
            bank_reg_number1 = bank_warp_num1;
        end else if (cache_request1) begin

        end else if (bank_warp_request2) begin
            // todo for now ignore the
            // documentation below. 

            // make the operand collector
            // first then have it pass
            // the variable into the 
            // bank module.
            bank_read2 = warp_read2;
            bank_write2 = warp_write2;
            bank_reg_number2 = bank_warp_num2;
        end else if (cache_request2) begin

        end

    end

endmodule