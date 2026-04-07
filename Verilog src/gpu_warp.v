module gpu_warp(
	input wire clk,
	input wire [15:0] pc,
	input wire instruction1 [63:0],
	input wire instruction2 [63:0],
	input wire bank_unveil_1, // ignore size for now.
	input wire bank_unveil_2, // ignore size for now.
	input wire [7:0] unveiled_input,
	output wire cache_request1,
	output wire cache_request2,
	output wire [0:63] bank_request_read,
	output wire [0:63] bank_request_write,
	output wire bank_warp_num,
	output reg [15:0] pc_out

	);
	
	genvar i, j;
	// convergence barriers will be hardcoded
	// for the moment!!!!
	
	reg [31:0] barrier_participation_mask;
	//tracks which threads participate in a
	// given convergence barrier.
	reg [31:0] barrier_state_field;
	// tracks which threads have arrived 
	// at a given convergence barrier.
	
	
	wire operand_type_1; // Will not take intermediate value.
	// 00 reg
	// 01 mem
	wire [1:0] operand_type_2;
	// 00 reg
	// 01 mem
	// 10 intermediate value.
	
	wire [1:0] operand_size_1;
	// 00 8 bit
	// 01 16 bit
	// 10 32 bit
	// 11 64 bit
	wire [1:0] operand_size_2;
	// 00 8 bit
	// 01 16 bit
	// 10 32 bit
	// 11 64 bit
	
	wire [5:0] opcode; // 6 bits.

	reg opcodes_unveiled;
	
	reg branch_happening; // Both correlate to the threads. 
	reg branch_taken; 

	reg [5:0] unveiled_list_1 [0:5]; // 32 bit x 32 bit list. 
	reg [5:0] unveiled_list_2 [0:5]; // 32 bit x 32 bit list. 

	assign opcode = gpu_file[pc][141:137];
	
	assign address_opcode_1 = gpu_file[pc][136:133]; // 5 bits. FIX THIS
	assign address_opcode_2 = gpu_file[pc][132:128]; // 5 bits. FIX THIS
	assign inst1 = gpu_file[pc][127:64]; // Make gpu_file
	assign inst2 = gpu_file[pc][63:0];
	
	generate
		for (i = 0; i < 32; i = i + 1) begin
			gpu_thread_decode gtd(
				.clk(clk), 
				.address_1(),
				.address_2(),
				.mem_in1(),
				.mem_in2(),
				.mem_out1(),
				.mem_out2(), 
				);
			
			gpu_thread_execute gte(
				);
		end
	endgenerate
	
	initial begin
		$display("gpu_warp");
		program_counter = pc;
		$readmemh("gpu_instruction.txt", gpu_file);
	end	
	
	always@( posedge clk ) begin
		if (!opcodes_unveiled) begin // thread decode stage.
			//
			// Operand Size related stuff.
			//
			
			operand_size_1 = address_opcode_1; // Actually allocate this properly.
			operand_type_1 = address_opcode_1; // Actually allocate this properly. 
			operand_size_2 = address_opcode_2;
			operand_type_2 = address_opcode_2;
			
			if (operand_size_1 != operand_size_2) begin  
				// Implement movzx and movsx handling.
			end
			
			//
			// Operand unveiling.
			//
			
			if (operand_type_1 == 0) begin // reg
				bank_request_1 = inst1;
			end
			
			if (operand_type_2 == 0) begin // reg
				bank_request_2 = inst2;
			end
			
			if (operand_type_1 == 1) begin // mem
			
			end
			
			if (operand_type_2 == 1) begin // mem
			
			end
			
			//
			// writeback
			//
			
			if (bank_set != 0) begin
				if (bank_set == 1) begin
					
				end
				if (bank_set == 2) begin
				
				end
				if (bank_set == 3) begin
				
				end
			end
		end
		
		else begin // thread execute stage
			
		end
	end // always
endmodule