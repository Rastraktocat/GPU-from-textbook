module gpu_streaming_multiprocessor(
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
	reg bank_reg_num_read[0:63];
	reg bank_reg_num_write[0:63];
	reg warp_reg_num_read[0:63]; 
	reg warp_reg_num_write[0:63]; 
	wire bank_read_boolean;
	wire bank_write_boolean;
	reg [0:2047] bank_out;

	reg [5:0]unveiled_list_warps [0:1]; // Fix the allocation.
	// first 32 are inst1
	// last 32 are inst2. Made for all of the 4 warps. 

	genvar i;
	integer k;
	generate
		for (i = 0; i < 4; i = i + 1) begin
			//update the ports!!!!!.
			gpu_warp gp( 
				.clk(clk),
				.pc(),
				.instruction1(),
				.instruction2(),
				.cache_request1(cache1[i*32:(i*32+31)]), // confirm this works
				.cache_request2(cache2[i*32:(i*32+31)]), // confirm this works
				.cache_in1(cache_out),
				.bank_request_read(warp_reg_num_read),
				.bank_request_write(warp_reg_num_write),
			);
		end
	endgenerate
	
	gpu_cache_L1 gcl(
		.clk(clk), 
		.in_frame(),
		.in_request(cache_request), 
		.cache_hit_or_miss(cache_return), 
		.out(cache_out)); 
	
	gpu_bank gb( // fix port declaration.
		.clk(clk), 
		.read_bank(bank_read_boolean),
		.write_bank(bank_write_boolean),
		.in(bank_reg_num_write),
		.reg_num(bank_reg_num_read),
		.bank_warp_num(),
		.out());
	
	always@(posedge clk)begin
		for (k = 0; k < 32; k = k + 1) begin // implement coalescing
			coalesce_table = cache_request1[k:k+32]; // fix this.
			coalesce_table = cache_request2[k:k+32]; // fix this.
		end
		
		// 
		// Bank can only read or write one after another.
		// Reads are prioritized.
		//
		
		if (warp_reg_num_read != 0) begin
			bank_reg_num_read = warp_reg_num_read; 
			bank_read_boolean = 1;
			bank_write_boolean = 0; 
		end
		
		if (warp_reg_num_read == 0 and warp_reg_num_write != 0) begin // fix this
			bank_read_boolean = 0;
			bank_write_boolean = 1;
		end
		
		// writeback
		
		// mov rax, 1
		if (bank_out != 0) begin
		
		end
		
		if (cache_out != 0) begin
		
		end
		
	end
	
endmodule