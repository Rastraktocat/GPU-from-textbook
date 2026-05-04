
module gpu_tb;
    import gpu_structs::*;
    logic mem; 
    // this is for simulating fetching
    // instructions. Size - 2+4+32+128
    logic rst;

    logic clk = 0;

    logic pc_test;

    single_warp_inst_t single_warp_inst;

    always #1 clk = ~clk;

    gpu g(
        .clk(clk),
        .rst(rst),
        .inst(single_warp_inst),
        .pc(pc_test)
    );

    gpu_thread gt(
        .clk(clk),
        .thread_pc(),
        .inst(),
    );
    
    initial begin
        rst = 0;
        // implement here.
    end

endmodule 