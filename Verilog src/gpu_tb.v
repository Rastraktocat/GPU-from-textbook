`timescale 1ps/1ps
module gpu_tb;
	reg clk;
	reg [3:0] pc;
	reg [3:0] highest_num;
	wire exit;
	wire exit_;
	always #1 clk = ~clk;
	
	gpu g(.clk(clk), .pc(pc), .highest_num(highest_num), .exit(exit), .exit_(exit_));
	
	initial begin
		$display("gpu_tb");
		pc = 0; 
		highest_num = 8;
		#1
		pc = 1; 
		#1
		pc = 2;
		#1
		pc = 3;
		#1
		pc = 4;
		#1
		pc = 5;
		#1
		pc = 6;
		#1
		pc = 7;
		$finish;
	end

endmodule