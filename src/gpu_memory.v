module gpu_memory(
	input wire clk,
	input wire [5:0] warp_num,
	input wire opc, 
	input wire register,
	input wire memory,
	input wire read,
	input wire write, 
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
	
	always@(posedge clk) begin
		read_mem <= 0; 
		read_bank <= 0;
		write_mem <= 0; 
		write_bank <= 0;
		if (memory) begin
			read_mem <= read;
			write_mem <= write;
		end
		if (register) begin
			read_reg <= read;
			write_reg <= write;
		end
		
	end // always
	
endmodule