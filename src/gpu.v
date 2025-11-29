module gpu(
	input wire clk,
	input wire [15:0] pc, 
	input wire [15:0] highest_num, 
	output wire exit,
	output reg exit_
	);
	
	reg [15:0] pc_in;
	reg [15:0] pc_out;
	integer i;
	
	gpu_warp gw(.clk(clk), .pc(pc_in), .exit(exit), .pc_out(pc_out));
	gpu_cache_L1 gcl();
	
	initial begin
		$display("gpu");
		pc_in <= pc;
	end
	
	always@(posedge clk) begin
		if (exit) begin
			exit_ <= 1;
		end
		else if (pc_in < highest_num) begin
			pc_in <= pc_out;
			exit_ <= 0; 
		end
		else begin
			exit_ <= 1;
		end
	end
	
endmodule