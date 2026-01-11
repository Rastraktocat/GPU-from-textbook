module gpu_cache(
	input wire clk,
	input wire in_frame,
	input wire in_request [0:12], 
	input wire cache_hit_or_miss,
	output wire out [0:255]
	);
	
	// This cache is set-associative. 32 frames. 
	// 16 tags per frame. Each data has 256 bits. 
	
	reg [12:0] frame [0:31]; // 5 bits for frames. 8 for offset. All data is gotten at once.
	reg prt;
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin
			
		end
	endgenerate
	
	always@(posedge clk) begin
		
	end
	
endmodule