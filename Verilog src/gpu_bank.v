module gpu_bank(
	input wire clk,
	input wire read_bank,
	input wire write_bank,
	input wire [0:2047] in,
	input wire [63:0] reg_num,
	input wire [1:0] bank_warp_num,
	output reg [0:2047] out 
	); 
	
	reg [63:0] bank_contents[0:4095]; 
	// 32 lane 4 banks representing 8 64-bit 32-register register files in 32x4 configuration.
	// with 8 register files in 1 bank. 
	// Banks are represented on top of each other in this case.
	
	integer i;
	reg [63:0] bank_current;
	reg [2047:0] bank_out;
	reg [7:0] idx;
	
	always@(posedge clk) begin
		
		//
		// bank swizzling formula 
		// (warp number (0-3) * 1024) + reg_num (0-31) * (index * 32) + index
		//		
		
		
		// THIS THEORETICALLY WORKS BUT VERILOG CANNOT HANDLE 
		// VARIABLES IN ARRAY FIELDS. IDX CURRENTLY BREAKS 
		// THE PROGRAM
		
		bank_current <= reg_num; 
		if (read_bank) begin 
			for (i = 0; i < 32; i = i + 1) begin
				idx <= i;
				bank_out[(idx*64)+63:idx*64] 
					<= bank_contents[(bank_warp_num*1024) + (i * 32) + reg_num + i];
			end
			out <= bank_out;	
		end
		
		if (write_bank) begin
			for ( i = 0; i < 32; i = i + 1) begin
				bank_contents[(bank_warp_num*1024) + (i * 32) + reg_num + i] <= in[i];
			end
		end
	end
endmodule