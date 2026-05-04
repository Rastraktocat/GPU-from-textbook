module gpu_coalescer(
    input logic clk,

    input logic input_array,
    // todo update size.
    
    output logic coalesce_designator_array,
    // todo update size in theory.
    // in acutuality it currently will
    // on max at 5.
    output logic out_array
    // todo update size.
);

    import gpu_structs::*;
    ////////////////////////////////

    // This is the coalescing module
    // todo make the algorithm run for
    // now but it should be improved
    // in the future.

    ////////////////////////////////

    logic coalesce_variable1;
    // the variables used to check
    // against values and coalesce 
    // them.
    // todo update all sizes.
    logic coalesce_variable2;
    logic coalesce_variable3;
    logic coalesce_variable4;
    logic coalesce_variable5;

    logic coalesce_values;
    // todo determine the size of this.
    logic coalesce_counter;
    // this is to count the number the index
    // that the coalesce value is at.

    logic non_coalesce_values;
    // todo determine the size of this.
    // it should be the same size as coalesce
    // values.
    logic non_coalesce_counter;

    integer i; 

    always_ff@(posedge clk) begin 

        for (i = 0; i < ; i = i + 1) begin
        // todo fix how many times the loop runs

            if (i >= 5) begin
                case (input_array[i]) 
                    coalesce_variable1: begin 
                        coalesce_values[coalesce_counter] = 
                        coalesce_counter = coalesce_counter + 1;
                    end
                    coalesce_variable2: begin
                        // same as case1
                    end
                    coalesce_variable3: begin
                        // same as case1
                    end
                    coalesce_variable4: begin
                    end
                    coalesce_variable5: begin
                    end
                    default: begin
                        non_coalesce_values[non_coalesce_counter] = 
                        non_coalesce_counter = non_coalesce_counter + 1;
                    end

                    // todo fix all of this and make it so that 
                    // this reads the first few bits at
                    // an array index. 

            endcase 
            end // if

            else if (i == 31) begin // todo this may change to 32.
                // todo implement how the coalescer 
                // writes to output.
            end // else if 

            else begin
                case (i) 
                'd0: coalesce_variable1 = input_array[0];
                'd1: coalesce_variable2 = input_array[1];
                'd2: coalesce_variable3 = input_array[2];
                'd3: coalesce_variable4 = input_array[3];
                'd4: coalesce_variable5 = input_array[4];
                endcase
                // todo add a default if necessary.
            end // end

        end // for

    end // always

endmodule