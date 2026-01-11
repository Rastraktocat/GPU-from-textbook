module gpu_thread_execute(
	input wire clk,
	input wire [3:0] program_counter, 	
	input wire priority_message, // For updating thread_active state and stuff.
	input wire in1, 
	input wire in2, 
	output wire branch_happening,
	output wire branch_taken // If the conditon was true or not.
);
	reg [3:0] pc;
	reg [71:0] gpu_file [0:7];
	
	reg [31:0] thread_state; // size subject to change.
	// Signifies whether a thread is ready to execute, 
	// blocked at a convergence barrier (specify which) , 
	// or has yielded. 
	reg [31:0] thread_rPC_state; // the next address to run. 
	// only when not running.
	reg thread_active;
	// active in the warp or not.
	
	
	wire [1:0]mem_type_1;
	// 00 is reg
	// 01 is mem
	// 10 is intermediate value.
	wire [1:0]mem_type_2;
	// 00 is reg
	// 01 is mem
	// 10 is intermediate value.
	
	wire [5:0] opcode; // 6 bits.
	
	assign opcode = gpu_file[pc][71:66];
	assign inst1 = gpu[pc][65:33]; // modify the size when necessary.
	assign inst2 = gpu[pc][32:0]; // modify the size if necessary.
	
	reg c_flag; 
	reg o_flag;
	reg z_flag;
	reg s_flag;
	// A final interpretation would put all of these into 1 big register.
	
	reg float_invalid; // No math defined result (0/0, sqrt -1 )
	reg float_div_zero; // dividing by zero.
	reg float_overflow; // too large to be represented. (1e308 * 1e308). 
	reg float_underflow; // too small to be represented. (-1e308 - 1e308).
	reg float_inexact; // needs to be rounded (1/3 and pi).
	
	initial begin
		pc <= program_counter;
		$display("gpu_thread");
		$readmemh("gpu_instruction.txt", gpu_file);
	end
	
	always@(posedge clk) begin
		$display("gpu_thread1");
		// Every time that one of the opcodes fits into one 
		// of the if statements then turn on the bit in the run vector.
		
		//
		// 0 - 13 alu
		//
		
		if ( 0 <= opcode <= 13) begin 
			if (opc == 0) begin // add
				assign out = in1 + in2;
				assign c_flag = out[32];
				assign o_flag = (~in1[32] & ~in2[32] & out[32]) | (in1[32] & in2[32] & ~out[32]);
				pc_out <= pc_out + 1;
			end
			if (opc == 1) begin // sub
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
		
		//
		// jump engine.
		//
		
		if (28 <= opcode <= 40) begin 
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
	end
endmodule