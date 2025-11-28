module register_file(
		input wire clk,
		input wire [31:0] register_num, // 32 registers per register file. 
		input wire read,
		input wire write,
		input wire [63:0] in, 
		output reg [63:0] out
	);
	reg [63:0] mem [0:31]; // intended to be 32 64-bit registers. 
	always@(posedge clk) begin
		if (write) begin
			mem[register_num] <= in;
		end
		else if (read) begin
			out <= mem[register_num];
		end
	end
endmodule