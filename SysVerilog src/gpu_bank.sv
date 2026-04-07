module gpu_bank(
    input logic clk,
    input logic [1:0] warp_num,
    // There are 4 warps
    input logic read,
    input logic write,
    input logic in_reg1,
    input logic in_reg2,
    ////////////////////////
    
    input logic in_reg_num1,
    input logic in_reg_num2,
    // TODO specify size
    ////////////////////////

    output logic [1:0] completed_request_warp_num,
    output logic [31:0] threads_satisfied,
    // which of the threads received
    // valid outputs and which weren't
    // hit on this run.

    output logic requested_out
    // todo fix size.
);

    // This is the module for 
    // storing and requesting
    // registers (aka banks)

    logic [0:3][2047:0][31:0] bank_cells;
    // 64 bit registers.
    // 32 registers | 32 registers
    // 4 warps | 1024 registers in total
    // 65536x4 bits in total.
    
    // There are 16 banks and 32 lanes.

    integer idx;
    integer read_queue_size;
    logic [4:0] read_request_queue [$:5];
    // This will take the inputs
    // that have not yet been
    // processed. 
    // TODO fix the size later.
    integer write_queue_size;
    logic [4:0] write_request_queue [$:5];
    // todo fix the size later.
    logic current_extracting_reg;
    // TODO fix the size later.
    logic need_new_extracting_reg;

    always_ff@( posedge clk ) begin
        
        ////////////////////////////

        // the request will first be sent to a queue

        //////////////////////////

        if (request_queue.size() != queue_size) begin
            if (in_reg1) begin
                queue_size++;
                request_size.push_back(in_reg_num1);
            end 
            if (in_reg2) begin
                queue_size++;
                request_size.push_back(in_reg_num2);
            end
        end

        if (need_new_extracting_reg) begin
            current_extracting_reg = request_queue.pop_front();
            queue_size--; // this may not be true.
        end
        else begin
            // todo make the current extracting
            // reg update itself until the 
            // regs have all been sent to 
            // the output.
        end

        //////////////////////////////
        
        // the request will then be looked at by the 

        ///////////////////////////////

        for (idx = 0; idx < 32; idx = idx + 1) begin
            requested_out = bank_cells [warp_num][idx*32+current_extracting_reg+idx];
        end
        // todo determine size of requested out and the times
        // the loop runs. if the lane number switches the 
        // times the loop runs will change. 

    end

endmodule