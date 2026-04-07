module errors(
    input wire clk,
    input wire test,
    input wire a,
    input wire b,
    output reg c
);
    reg d;
    reg e;

    wire [7:0] f;
    wire [3:0] g;

    reg enable;

    // this is fine.
    assign f = g; 
    // this will silently
    // truncate the upper
    // 4 bits. 
    assign g = f; 

    always@(posedge clk) begin
        // This is a runtime 
        // error caused because
        // Verilog is not good 
        // at preventing race 
        // conditions. 

        // This can be especially 
        // bad if they both have 
        // the same logic cone.  
        
        // A logic cone refers
        // to fan-in and fan-out.

        // The fan-in inputs also
        // capture inputs that 
        // indirectly influence
        // an input such as the
        // inputs of a mux who's 
        // output will be taken 
        // as input for the mux. 

        // The fan-out outputs
        // are the same but 
        // for output logic. 

        c <= a;
        if (test) begin
            c <= b;
        end

        // This code is 
        // trying to model 
        // the swapping of 
        // content in registers.
        
        // In reality both 
        // flip flops retain
        // the old values
        // because the 
        // hardware updates
        // in parallel.

        d = e;
        e = d;

        // The hardware will
        // create an implied
        // latch. You fix this
        // by adding an else
        // statement.

        if (enable) begin
            c = a;
        end

    end
endmodule
