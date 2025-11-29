module gpu_memory(
	input wire clk,
	input wire register,
	input wire memory,
	input wire read,
	input wire write, 
	input wire [5:0] warp_num,
	input wire offset,
	input wire index, 
	input wire tag,
	output wire hit,
	output wire[63:0] out
	);
	genvar i;
	reg read_mem;
	reg write_mem;
	reg read_reg;
	reg write_reg;
	generate 
	// Each bank has 8 register files.
	// 4 banks per warp.
		for (i = 0; i < 4; i = i + 1) begin : banks
			gpu_bank gb(
				.clk(clk),
				.read(read_reg),
				.write(write_reg),
				.target_reg(),
				.in(),
				.write_out(),
				.out()
				);
		end
	endgenerate
	
	gpu_cache_L1 gcl(); 
	// 64 bit data blocks.
	// Set associative cache
	// Write-allocate
	
	always@(posedge clk) begin
		read_mem <= 0; 
		read_reg <= 0;
		write_mem <= 0; 
		write_reg <= 0;
		if (memory) begin
			read_mem <= read;
			write_mem <= write;
		end
		if (register) begin
			read_reg <= read;
			write_reg <= write;
		end
		
		//Make a global memory policy. 
	end // always
		
	
endmodule