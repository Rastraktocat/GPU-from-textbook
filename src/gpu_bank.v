module gpu_bank(
	input wire clk,
	input wire read_bank,
	input wire write_bank,
	input wire [5:0] target_reg,
	input wire [63:0] in,
	output wire write_out,
	output wire [63:0] out
	); // This may be subject to change if I learn how to do this better.
	reg [63:0] mem [0:255]; // intended to be 32 64-bit registers times 8. 
	always@(posedge clk) begin
		if (write) begin
			mem[(32*reg_offset) + target_reg] <= in;
		end
		else if (read) begin
			assign write_out = 1;
			assign out = mem[(32*reg_offset) + target_reg];
		end
	end
endmodule