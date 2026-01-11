gpu_streaming_multiprocessor(
	input wire clk,
	input wire rst,
	// Make the output information 
	// on the warp running and other 
	// notable data
	);
	reg [255:0] cache1[0:31];
	reg [255:0] cache2[0:31];
	reg cache_request [0:12];
	reg cache_out[0:255];
	reg cache_return_status;
	reg coalesce_table;
	reg coalesce_cache;
	
	
	genvar i;
	integer k;
	generate
		for (i = 0; i < 4; i = i + 1) begin
			gpu_warp gp(
				.clk(clk),
				.pc(),
				.cache_request1(cache1[i*32:(i*32+31)]), // confirm this works
				.cache_request2(cache2[i*32:(i*32+31)]), // confirm this works
				.cache_in1(cache_out),
				.bank_request1(),
				.bank_request2(),
			);
		end
	endgenerate
	
	
	gpu_cache_L1 gcl(
		.clk(clk), 
		.in_frame(),
		.in_request(cache_request), 
		.cache_hit_or_miss(cache_return), 
		.out(cache_out));
	
	gpu_bank gb( // use 1024 x 4 registers in register files
		.clk(clk), // warp scheduling will be handled by the SM. 
		.read_bank(),
		.write_bank(),
		.in(),
		.bank_warp_num(),
		.out());
	
	always@(posedge clk)begin
		for (k = 0; k < 32; k = k + 1) begin // implement coalescing
			coalesce_table = cache_request1[k:k+32]; // fix this.
			coalesce_table = cache_request2[k:k+32]; // fix this.
		end
		
	end
	
endmodule