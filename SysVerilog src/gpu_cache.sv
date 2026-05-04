module gpu_cache #(
    parameter NUM_SETS = 256,
    // This refers to the actual number of sets there
    // are 
    parameter WAYS_PER_SET = 4,
    // This is referring to the amount of
    // cache lines in a single set. 
    parameter BLOCK_SIZE = 64*2,
    // The block size is the size that the cache
    // recovers at a time. 

    // This is a modelling a 128kb cache.
    // cache_capacity / (WAYS_PER_SET * BLOCK_SIZE) = NUM_SETS
    // 128kb / (4 ways x 128 block_size) = 256 NUM_SETS
    // Supposedly there are a high amount of sets
    // because having a small amount of sets would
    // cause thrashing and low effective hit rates.
    // todo check if these are the correct
    // formulas. 

    parameter OFFSET_BITS = 7,
    // OFFSET_BITS = log2 (BLOCK_SIZE)
    // log2 (128) = 7
    parameter INDEX_BITS = 8, 
    // INDEX_BITS = log2 (NUM_SETS)
    // log2 (256) = 8


    parameter INPUT_ADDRESS_HIGH_BOUND = 64,
    localparam EFFECTIVE_HIGH_ADDRESS = INPUT_ADDRESS_HIGH_BOUND -1,
    localparam EFFECTIVE_LOW_ADDRESS = (INPUT_ADDRESS_HIGH_BOUND-1)-INDEX_BITS-OFFSETS_BITS,
    // These bounds are mostly for handling 
    // getting the tag of the cache. 

    parameter PRT_TABLE_ENTRY_NUM = 
    

    ) ( 
    input logic clk,    

    input logic cache_read_write,
    // 1 means read 0 means write

    input logic cache_input_address,
    // todo rename this. 
    // todo fix size


    output logic prt_request,
    output logic hit_or_miss
);

    import gpu_structs::*;
    /////////////////////////////////////////////

    // This is the module that handles all of the
    // caching logic in the gpu.

    /////////////////////////////////////////////

    logic [NUM_SETS-1:0][WAYS_PER_SET-1:0][BLOCK_SIZE-1:0] cache; 

    // This cache uses write-back caching.

    logic prt_table;
    // todo fix the sizing.

    always_ff@(posedge clk) begin
        if (cache_read_write == 0) begin // write

        end 
        else begin // if cache_read_write == 1 | read

            case (cache_input_address [EFFECTIVE_HIGH_ADDRESS:EFFECTIVE_LOW_ADDRESS]) 
            

            endcase
            // todo determine the memory 
            // ranges the gpu will cover. 
            // todo Determine tag size.
            // todo implement cache 

        end
    end

endmodule 