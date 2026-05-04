module gpu_bank #(

    parameter PC_BIT_SIZE = 16,

    parameter REJECT_QUEUE_VAR_SIZE = 4,
    // when the requests are being put into a
    // queue the initial size the queue can handle
    // before it starts putting requests into the 
    // overflow queue so it can start rejecting inputs
    // is QUEUE_SIZE. 
    
    // Rejecting inputs has not been implemented yet.

    parameter QUEUE_VAR_SIZE = 6,
    // This is what would be on the queue. In a variable
    // declaration having [QUEUE_SIZE:0] <var> would represent
    // a variable of size 7. In binary this that can represent
    // a max of 128 different values. It can also be used to 
    // represent two different 64 bit values. 

    parameter FIRST_QUEUE_SIZE = 6,
    parameter REJECT_QUEUE_SIZE = 2,
    // these represent the number of variables each queue can take.

    parameter BITS_PER_REG = 64,
    parameter REG_PER_THREAD = 32,
    parameter NUM_THREADS_PER_WARP = 32,
    parameter NUM_WARPS = 4,
    // All of these values correlate to different aspects
    // relating to the bank. 

    parameter INPUT_REG_SIZE = 64
    // currently unused.

    ) (
    input logic clk,
    input logic [1:0] warp_num,
    // There are 4 warps

    input logic bank_read1,
    input logic bank_read2,
    input logic bank_write1,
    input logic bank_write2,
    
    ////////////////////////
    input logic [63:0] bank_reg_num1,
    input logic [63:0] bank_reg_num2,
    // TODO specify size
    ////////////////////////

    output logic [1:0] completed_request_warp_num,
    output logic [31:0] bank_threads_satisfied,
    // which of the threads received
    // valid outputs and which weren't
    // hit on this run.
    // todo put this to actual use.

    output logic bank_write_complete,
    output logic [31:0][63:0] bank_warp_requested_out
    // change this to an array.
);

    import gpu_structs::*;
    // This is the module for 
    // storing and requesting
    // registers (aka banks)

    logic [NUM_WARPS-1:0][NUM_THREADS_PER_WARP*REG_PER_THREAD-1:0][BITS_PER_REG-1:0] bank_cells;
    // 64 bit registers.
    // 32 registers | 32 threads
    // 4 warps | 1024 registers in total
    // 65536x4 bits in total. 
    
    // There are 16 banks and 32 lanes.

    logic skip;
    logic [0:1][0:5] scoreboard;
    // the first bits are for the
    // warp and the last few are for 
    // the register number.

    integer idx;

    integer read_queue_size;
    logic [QUEUE_VAR_SIZE:0] read_request_queue [$:FIRST_QUEUE_SIZE-1];
    logic [QUEUE_VAR_SIZE:0] read_request_queue_runoff[$:REJECT_QUEUE_SIZE-1];
    // This will take the inputs
    // that have not yet been
    // processed. 

    integer write_queue_size;
    logic [QUEUE_VAR_SIZE:0] write_request_queue [$:FIRST_QUEUE_SIZE-1];
    logic [QUEUE_VAR_SIZE:0] write_request_queue_runoff [$:REJECT_QUEUE_SIZE-1];
    // todo fix the size later and 
    // add handling of a write queue.
    logic [4:0] current_extracting_reg;

    logic [QUEUE_VAR_SIZE:0] queue_buffer;
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

        if (read_request_queue.size() <= REJECT_QUEUE_SIZE) begin
            if (bank_read1) begin
                read_request_queue.push_back({warp_num, bank_reg_num1});
            end
            if (bank_read2) begin
                read_request_queue.push_back({warp_num, bank_reg_num2});
            end

            // todo find the correct size.
        end else begin
            if (bank_read1) begin
                read_request_queue_runoff.push_back({warp_num, bank_reg_num1});
            end
            if (bank_read2) begin
                read_request_queue_runoff.push_back({warp_num, bank_reg_num2});
            end
        end

        if (write_request_queue.size() <= REJECT_QUEUE_SIZE) begin
            if (bank_write1) begin
                write_request_queue.push_back({warp_num, bank_reg_num1});
            end
            if (bank_write2) begin
                write_request_queue.push_back({warp_num, bank_reg_num2});
            end
            // todo find the correct size.
        end else begin
            if (bank_write1) begin
                write_request_queue_runoff.push_back({warp_num, bank_reg_num1});
            end
            if (bank_write2) begin
                write_request_queue_runoff.push_back({warp_num, bank_reg_num2});
            end
        end

        if (read_request_queue.pop_front() == scoreboard) begin
            read_request_queue.push_front(scoreboard);
            skip = 1;
        end
        else if (read_or_write == 0) begin // read
            skip = 0;
            queue_buffer = read_request_queue.pop_front();
            completed_request_warp_num = queue_buffer[6:5];
            current_extracting_reg = queue_buffer[4:0];
        end
        else begin
            skip = 0;
            queue_buffer = write_request_queue.pop_front();
            completed_request_warp_num = queue_buffer[6:5];
            current_extracting_reg = queue_buffer[4:0];
        end

        //////////////////////////////
        
        // the request will then be looked at by the 

        ///////////////////////////////

        if (skip == 0) begin
            for (idx = 0; idx < 32; idx = idx + 1) begin
                bank_warp_requested_out [idx] = bank_cells [warp_num][idx*32+current_extracting_reg+idx];
            end
        end
        // todo determine size of requested out and the times
        // the loop runs. if the lane number switches the 
        // times the loop runs will change. 

    end

endmodule