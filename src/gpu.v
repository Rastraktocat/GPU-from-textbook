module gpu(
	input wire clk,
	input wire [3:0] pc, 
	input wire [3:0] highest_num, 
	output wire exit,
	output reg exit_
	);
	
	reg [3:0] program_counter;
	integer i;
	
	gpu_warp gw(.clk(clk), .pc(program_counter), .exit(exit));
	
	initial begin
		$display("gpu");
		program_counter <= pc;
	end
	
	always@(posedge clk) begin
		if (program_counter < highest_num) begin
			program_counter <= program_counter + 1;
			exit_ <= 0; 
		end
		exit_ <= 1;
	end
	
endmodule