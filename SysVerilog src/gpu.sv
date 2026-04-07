module gpu (
    input logic clk,
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
        single_warp_pc warp1_pc,
        single_warp_pc warp2_pc,
        single_warp_pc warp3_pc,
        single_warp_pc warp4_pc
    } all_warp_pc;

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

    logic mem;
    all_warp_pc pc;
    // this is the instruction
    // that will be passed in.
    logic [1:0] current_running_warp;

    logic bank_request1;
    logic bank_request2;
    logic cache_request_1;
    logic cache_request_2;
    // all of the cache and
    // bank requests are all
    // only to suggest that
    // one of the warps requests
    // information.

    logic bank_request_num1;
    logic bank_request_num2;
    logic cache_memory_request_1;
    logic cache_memory_request_2;
    // If the bank or cache is 
    // requested this is the 
    // memory location or register
    // that is to be requested. 

    // TODO determine the size.

    logic bank_register_request_output;
    // this is the output when the 
    // bank has finished getting 
    // the input.

    /////////////////////////////////////////

    // These are the module instantiations.

    /////////////////////////////////////////

    gpu_bank gb( 
        .clk(clk), 
        );

    gpu_warp gw (
        .clk(clk),
        .pc(pc),

    );

    always_ff@( posedge clk ) begin

        ////////////////////////////////////

        // todo Determine and Implement the 
        // operand collector for bank requests.
        
        ////////////////////////////////////

        if (bank_request1) begin
            // make the operand collector
            // first then have it pass
            // the variable into the 
            // bank module.
        end else if (cache_request1) begin

        end else if (bank_request2) begin
            // make the operand collector
            // first then have it pass
            // the variable into the 
            // bank module.
        end else if (cache_request2) begin

        end else begin

        end

    end

endmodule