module gpu_bank(
    input logic clk,
    input logic [1:0] warp_num,
    // There are 4 warps
    input logic read1,
    input logic read2,
    input logic write1,
    input logic write2,
    ////////////////////////
    
    input logic in_reg_num1,
    input logic in_reg_num2,
    // TODO specify size
    ////////////////////////

    output logic [1:0] completed_request_warp_num,
    output logic [31:0] bank_threads_satisfied,
    // which of the threads received
    // valid outputs and which weren't
    // hit on this run.
    output logic bank_write_complete,
    output logic [2047:0] requested_out
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

    logic scoreboard;
    // todo make this the correct size.

    integer idx;

    integer read_queue_size;
    logic [6:0] read_request_queue [$:5];
    logic [6:0] read_request_queue_runoff;
    // This will take the inputs
    // that have not yet been
    // processed. 
    // TODO fix the size later

    integer write_queue_size;
    logic [6:0] write_request_queue_runoff [$:1];
    logic [6:0] write_request_queue [$:5];
    // todo fix the size later and 
    // add handling of a write queue.
    logic current_extracting_reg;
    // TODO fix the size later.

    logic queue_buffer;
    logic read_or_write;
    // this is for determining
    // whether the bank should
    // handling reading or writing.
    // 0 is read | 1 is write.

    always_ff@( posedge clk ) begin

        if (read_or_write == 0 && write_request_queue.size() != 0 ) begin
            read_or_write = 1;
        end 
        else if (read_or_write == 1 && read_request_queue.size() != 0) begin
            read_or_write = 0;
        end        
        ////////////////////////////

        // the request will first be sent to a queue

        //////////////////////////

        if (read_request_queue.size() < queue_size) begin
            if (read1) begin
                read_request_queue.push_back({warp_num, in_reg_num1});
            end
            if (read2) begin
                read_request_queue.push_back({warp_num, in_reg_num2});
            end

            // todo find the correct size.
        end else begin
            if (read1) begin
                read_request_queue_runoff.push_back({warp_num, in_reg_num1});
            end
            if (read2) begin
                read_request_queue_runoff.push_back({warp_num, in_reg_num2});
            end
        end

        if (write_request_queue.size() < queue_size) begin
            if (write1) begin
                write_request_queue.push_back({warp_num, in_reg_num1});
            end
            if (write2) begin
                write_request_queue.push_back({warp_num, in_reg_num2});
            end
            // todo find the correct size.
        end else begin
            if (write1) begin
                write_request_queue_runoff.push_back({warp_num, in_reg_num1});
            end
            if (write2) begin
                write_request_queue_runoff.push_back({warp_num, in_reg_num2});
            end
        end

        // todo implement scoredboarding.

        if (read_or_write == 0) begin // read
            queue_buffer = read_request_queue.pop_front();
            completed_request_warp_num = [6:5] queue_buffer;
            current_extracting_reg = [4:0] queue_buffer;
        end
        else begin
            queue_buffer = write_request_queue.pop_front();
            completed_request_warp_num = [6:5] queue_buffer;
            current_extracting_reg = [4:0] queue_buffer;
        end

        //////////////////////////////
        
        // the request will then be looked at by the 

        ///////////////////////////////

        for (idx = 0; idx < 32; idx = idx + 1) begin
            requested_out [idx*32: idx*32+31] = bank_cells [warp_num][idx*32+current_extracting_reg+idx];
        end
        // todo determine size of requested out and the times
        // the loop runs. if the lane number switches the 
        // times the loop runs will change. 

    end

endmodule