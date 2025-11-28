module gpu_warp(
	input wire clk,
	input wire [3:0] pc, 
	output reg exit // warp finishes running.
	);
	reg write;
	reg read;
	wire bool;
	wire [5:0] opcode; // 6 bits.
	
	wire [3:0] address_opcode_1; //Make 2d
	
	// For the first operand.
	// 0 1 2 3 memory addresses 8, 16, 32, 64 bits.
	// 4 5 6 7 register values 8, 16, 32, 64.  
	
	wire [4:0] address_opcode_2; //Make 2d
	
	// For the second operand.
	// 8 9 10 11 intermediate values 8, 16, 32, 64 bits.
	assign opcode = gpu_file[pc][141:137];
	
	assign address_opcode_1 = gpu_file[pc][136:133]; // 5 bits.
	assign address_opcode_2 = gpu_file[pc][132:128]; // 5 bits.
	assign inst1 = gpu_file[pc][127:64]; // Make gpu_file
	assign inst2 = gpu_file[pc][63:0];
	
	wire [31:0] carry;
	reg [31:0] thread_array;
	
	reg modify;
	reg [3:0] program_counter;
	
	initial begin
		$display("gpu_warp");
		program_counter <= pc;
		$readmemh("gpu_instruction.txt", gpu_file);
	end	
	
	gpu_memory gm();
	
	always@( posedge clk ) begin
		read <= 0; 
		write <= 0; 
		$display("gpu_warp");
		if ( 0 <= opcode <= 13) begin // 0 - 13
			if (address_opcode_1 < 5) begin // This is just a testing check.
				assign bool = (address_opcode_2 - address_opcode_1) == 4 ? 1 : 
							   (address_opcode_2 - address_opcode_1) == 8 ? 1 :
							   (address_opcode_2 - address_opcode_1) == 12 ? 1 : 0; 
				if (bool == 1) begin
					
				end
			end
		
			if (opc == 0) begin
				assign out = in1 + in2;
				assign c_flag = out[32];
				assign o_flag = (~in1[32] & ~in2[32] & out[32]) | (in1[32] & in2[32] & ~out[32]);
			end
			if (opc == 1) begin
				assign out = in1 - in2;
				assign c_flag = out[32];
				assign o_flag = ~(~in1[32] & ~in2[32] & out[32]) | ~(in1[32] & in2[32] & ~out[32]);
			end
			if (opc == 2) begin
				assign out = in1 * in2;
			end
			if (opc == 3) begin
				assign out = in1 / in2;
			end
			if (opc == 4) begin
				assign out = in1 & in2;
			end
			if (opc == 5) begin
				assign out = in1 | in2;
			end
			if (opc == 6) begin
				assign out = in1 ^ in2;
			end
			if (opc == 7) begin
				assign out = in1 ~& in2;
			end
			if (opc == 8) begin
				assign out = in1 ~| in2;
			end
			if (opc == 9) begin
				assign out = in1 ~^ in2;
			end
			if (opc == 10) begin // shift left
				assign out = {out, [32-in2:0]in1}; // concatenate a new number.
			end
			if (opc == 11) begin // shift right
				assign out = {out, [32:in2]in1};
			end
			if (opc == 12) begin // rotate left
				assign out = {out, [32:in2]in1}; // Probably fix this. 
				assign out = {out, [in2:0]in1};
			end
			if (opc == 13) begin // rotate right
				assign out = {out, [32-in2:0]in1}; //shift but save carried numbers and add to end of out.
				assign out = {out, [32:32-in2]in1}; // Check to make sure this doesn't break!!!!!
			end
			assign z_flag = out == 0 ? 1 : 0;
			assign s_flag = out[63] == 1 ? 1 : 0;
		end
	if (14 <= opcode <= 22) begin // 14 - 22
		
	end
	
	if (23 <= opcode <= 27) begin // 23 - 27
	
	end
	
	end // always
endmodule