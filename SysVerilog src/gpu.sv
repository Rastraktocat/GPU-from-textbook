module gpu #(

    parameter PC_BIT_SIZE = 16;
    // This is the same for all modules.
    
    parameter INSTRUCTION_LINE_SIZE = ,
    // This is the number of lines in the 
    // instruction.txt file. 

    parameter OPCODE_BITS_SIZE = 5,
    // The number of bits in an opcode.
    // 2^5 = 32

    parameter OPERAND_SIZE_BITS = 2,
    // Currently there are only 2 bits. This
    // only needs to occur once because both
    // operands will be the same size currently.
    // movzx and movsx have not been implemented.
    // the operand size | made of 2 bits
    // 00 is 8 bits | 01 is 16 bits
    // 10 is 32 bits | 11 is 64 bits

    parameter ADDRESSING_MODE_BITS = 2,
    localparam TOTAL_ADDRESSING_SIZE = ADDRESSING_MODE_BITS * 2,

    parameter OPERAND_SIZE = 64,
    localparam TOTAL_OPERAND_SIZE = OPERAND_SIZE * 2,

    localparam TOTAL_INST_SIZE = OPCODE_BITS_SIZE +
                                 OPERAND_SIZE_BITS + 
                                 TOTAL_ADDRESSING_SIZE + 
                                 TOTAL_OPERAND_SIZE

    ) (
    input logic clk,
    input logic rst,
    output single_warp_inst_t inst,
    // todo determine size.
    output logic pc
    // todo fix this for all inputs in
    // the module.
);

    import gpu_structs::*;
    /////////////////////////////////////

    // This is the top level module for the gpu.
    // Its instantiates all of the submodules.

    /////////////////////////////////////
    

    logic [INSTRUCTION_LINE_SIZE-1:0][TOTAL_INST_SIZE-1:0] mem;

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
    logic cache_memory_request1;
    logic cache_memory_request2;
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

    logic pc_in;
    logic pc_out;
    // todo update the size.
    logic write_complete;
    logic [1:0] complete_warp_num;
    logic [31:0] threads_satisfied;    

    logic bank_out1;
    logic bank_out2;

    logic cache_requested_out1;
    logic cache_requested_out2;

    logic cache_read1;
    logic cache_read2;
    logic cache_write1;
    logic cache_write2;
    
    logic cache_out1;
    logic cache_out2;
    logic warp;

    logic in_cache_number1;
    logic in_cache_number2;
 

    logic writeback_buffer;

    all_warp_pc_t all_warp_pc;
    // todo fix name.

    logic [31:0][63:0] requested_out;

    initial begin
        // fopen is for debugging
        // readmemh is for sysverilog 
        $readmemh("instruction.txt", mem);
    end

    /////////////////////////////////////////

    // These are the module instantiations.

    /////////////////////////////////////////

    gpu_warp gw (

        .clk(clk),
        .warp_pc(all_warp_pc),
        .warp_inst(inst),
        
        .bank_warp_read1(read1),
        .bank_warp_read2(read2),
        .bank_warp_write1(write1),
        .bank_warp_write2(write2),
        .bank_request_in1(in_reg_number1),
        .bank_request_in2(in_reg_number2),
        .warp_write_complete(write_complete),
        .warp_write_complete_number(complete_warp_num),
        // todo finish adding all of the ports.

        .cache_warp_read1(cache_read1),
        .cache_warp_write1(cache_write1),
        .cache_warp_read2(cache_read2),
        .cache_warp_write2(cache_write2),
        .cache_request_in1(in_cache_number1),
        .cache_request_in2(in_cache_number2),

        .bank_warp_out1(bank_out1),
        .bank_warp_out2(bank_out2),

        .bank_warp_request_out(bank_requested_out),

        .cache_warp_out1(cache_out1),
        .cache_warp_out2(cache_out2),
        .cache_requested_out1(cache_requested_out1),
        .cache_requested_out2(cache_requested_out2),

        .writeback_buffer(writeback),
        .warp_pc_out(pc_out)
        // todo refractor everything here.
    );
    
    gpu_warp_scheduler gws(
        .clk(clk),
        .write_warp_num(),
        .jmp_pc_in(),
        .pc(),
        .pc_in(),
        .inst_out(),
        .pc_out()
        // todo fix ports.
    );

   gpu_bank #( 
        .PC_BIT_SIZE(PC_BIT_SIZE)
    ) gb (
            .clk(clk), 
            .warp_num(current_runing_warp),
            .bank_read1(read1),
            .bank_read2(read2),
            .bank_write1(write1),
            .bank_write2(write2),
            .bank_reg_num1(in_reg_number1),
            .bank_reg_num2(in_reg_number2),
            .completed_request_warp_num(complete_warp_num),
            .bank_threads_satisfied(threads_satisfied),
            .bank_write_complete(write_complete),
            .bank_warp_requested_out(requested_out)
    );

    //gpu_cache gc(
    //        .clk(clk),

    //);

    //gpu_coalescer gcoal(
    //        .clk(clK),

    //);

endmodule