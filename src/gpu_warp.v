module gpu_warp(
	input wire clk,
	input wire [15:0] pc, 
	output wire error,
	output reg exit, // warp finishes running.
	output reg [15:0] pc_out
	);
	wire [5:0] opcode; // 6 bits.
	
	wire [3:0] address_opcode_1; // Make 2d
	
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
	
	reg [3:0] program_counter;
	
	reg c_flag; 
	reg o_flag;
	reg z_flag;
	reg s_flag;
	// A final interpretation would put all of these into 1 big register.
	
	reg float_invalid; // No math defined result (0/0, sqrt -1 )
	reg float_div_zero; // dividing by zero.
	reg float_overflow; // too large to be represented. (1e308 * 1e308). 
	reg float_underflow; // too small to be represented. (1e308 - 1e308).
	reg float_inexact; // needs to be rounded (1/3 and pi).
	
	reg mem_;
	reg reg_;
	reg read;
	reg write;
	
	initial begin
		$display("gpu_warp");
		program_counter <= pc;
		$readmemh("gpu_instruction.txt", gpu_file);
	end	
	
	gpu_memory gm(.register(reg_), .memory(mem_), .read(read), .write(write), .hit(hit));
	
	always@( posedge clk ) begin
		$display("gpu_warp");
		
		assign error = (address_opcode_2 - address_opcode_1) == -4 ? 0 : 
					   (address_opcode_2 - address_opcode_1) == -8 ? 0 : 
				       (address_opcode_2 - address_opcode_1) == 4 ? 0 : 
					   (address_opcode_2 - address_opcode_1) == 8 ? 0 : 1;
		//
		// Make this like actual banks.
		//
		
		if (address_opcode_1 < 4) begin  
			mem_ <= 1;
			// set the read variable in the cache
			// write to the instruction variables.
		end
		else if (address_opcode_1 < 8) begin // make better.
			reg_ <= 1;
			in1 <= out;
		end
		if (address_opcode_2 < 4) begin 
			// set the read variable in the cache
			// write to the instruction variables.
		end
		else if (address_opcode_2 < 8) begin
			read_bank <= 1;
			in2 <= out;
		end
		
		//
		// Make this like actual banks.
		//
		
		if ( 0 <= opcode <= 13) begin // 0 - 13 alu
		
			
			if (opc == 0) begin // add
				assign out = in1 + in2;
				assign c_flag = out[32];
				assign o_flag = (~in1[32] & ~in2[32] & out[32]) | (in1[32] & in2[32] & ~out[32]);
				pc_out <= pc_out + 1;
			end
			if (opc == 1) begin
				assign out = in1 - in2;
				assign c_flag = out[32];
				assign o_flag = ~(~in1[32] & ~in2[32] & out[32]) | ~(in1[32] & in2[32] & ~out[32]);
				pc_out <= pc_out + 1;
			end
			if (opc == 2) begin
				assign out = in1 * in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 3) begin
				assign out = in1 / in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 4) begin
				assign out = in1 & in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 5) begin
				assign out = in1 | in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 6) begin
				assign out = in1 ^ in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 7) begin
				assign out = in1 ~& in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 8) begin
				assign out = in1 ~| in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 9) begin
				assign out = in1 ~^ in2;
				pc_out <= pc_out + 1;
			end
			if (opc == 10) begin // shift left
				assign out = {out, [32-in2:0]in1}; // concatenate a new number.
				pc_out <= pc_out + 1;
			end
			if (opc == 11) begin // shift right
				assign out = {out, [32:in2]in1};
				pc_out <= pc_out + 1;
			end
			if (opc == 12) begin // rotate left
				assign out = {out, [32:in2]in1}; // Probably fix this. 
				assign out = {out, [in2:0]in1};
				pc_out <= pc_out + 1;
			end
			if (opc == 13) begin // rotate right
				assign out = {out, [32-in2:0]in1}; //shift but save carried numbers and add to end of out.
				assign out = {out, [32:32-in2]in1}; // Check to make sure this doesn't break!!!!!
				pc_out <= pc_out + 1;
			end
			assign z_flag = out == 0 ? 1 : 0;
			assign s_flag = out[63] == 1 ? 1 : 0;
		end
		
		
	if (opcode == 14) begin // 14 only compare
		// ADD APPROPRIATE SIZES
		if ((in1 - in2) == 0) begin
			z_flag <= 1;
		end
		else begin
			z_flag <= 0; 
		end
		
		assign out = in1 - in2;
		
		if (out[63] == 1) begin
			s_flag <= 1;
		end
		else begin
			s_flag <= 0;
		end
		
		if (in1 - in2 >= 0) begin
			c_flag <= 1;
		end
		else begin
			c_flag <= 0;
		end
		
		if (in1 >=0 ) begin
			if(in2 < 0) begin
				if (out < 0) begin
					o_flag <= 1;
				end
				else begin
					o_flag <= 0;
				end
			end
			else begin
				o_flag <= 0; 
			end
		end
		else if (in1 < 0) begin
			if (in2 >= 0) begin
				if (out >= 0) begin
					o_flag <= 1;
				end
				else begin
					o_flag <= 0;
				end
			end
			else begin
				o_flag <= 0; 
			end
		end
		
	end
	
	if (23 <= opcode <= 27) begin // 15 - floats
		if (opcode == 23) begin
			assign out 
		end
	end
	
	
	if (28 <= opcode <= 40) begin // 28 - 40 jumps
		if (opcode <= 29) begin 
			if (z_flag == 1 and opcode == 28) begin // je
				pc_out <= in1;
			end
			else begin //jne
				pc_out <= pc_out + 1;
			end
		end
		else if (opcode <= 33) begin 
			if (opcode <= 31) begin // jl
				if (s_flag != o_flag) begin
					pc_out <= in1;
				end
				else if (opcode == 31 and z_flag == 1) begin // jle
					pc_out <= in1;
				end
				else begin
					pc_out <= pc_out + 1;
				end
			end
			else begin
				if (s_flag == o_flag) begin // jg
					pc_out <= in1;
				end
				else if (opcode == 33 and z_flag == 1) begin // jge
					pc_out <= in1;
				end
				else begin
					pc_out <= pc_out + 1;
				end
			end
		end
		else if (opcode <= 37) begin 
			if (opcode == 34) begin //ja
				if (c_flag == 0 and z_flag == 0) begin
					pc_out <= in1;
				end
			end
			else if (opcode == 37) begin //jbe
				if (c_flag == 1 or z_flag == 1) begin
					pc_out <= in1;
				end
			end
			else begin
				if (opcode == 35) begin //jae
					if ( c_flag == 0 ) begin 
						pc_out <= in1;
					end
					pc_out <= pc_out + 1;
				end
				else begin
					if (c_flag == 1) begin // jb
						pc_out <= in1;
					end
					pc_out <= pc_out + 1;
				end
			end
		end
		else if (opcode == 38) begin // js
			if (s_flag == 1) begin
				pc_out <= in1;
			end
			else begin
				pc_out <= pc_out + 1;
			end
		end
		else if (opcode == 39) begin // jc
			if (c_flag == 1) begin
				pc_out <= in1;
			end
			else begin
				pc_out <= pc_out + 1;
			end
		end
		else if (opcode == 40) begin // jo
			if (o_flag == 1) begin
				pc_out <= in1;
			end
			else begin
				pc_out <= pc_out + 1;
			end
		end
	end
	
	end // always
endmodule