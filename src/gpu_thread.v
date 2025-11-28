module gpu_thread(
	input wire clk,
	input wire [3:0] program_counter, 	
	output reg math, condition, fpu, io, stop
);
	integer i;
	integer j;
	reg [3:0] pc;
	reg [71:0] gpu_file [0:7];
	wire [5:0] opcode; // 6 bits.
	reg run; 
	assign opcode = gpu_file[pc][71:66];
	assign inst1 = gpu[pc][65:33]; // modify the size when necessary.
	assign inst2 = gpu[pc][32:0]; // modify the size if necessary.
	
	initial begin
		pc <= program_counter;
		$display("gpu_thread");
		$readmemh("gpu_instruction.txt", gpu_file);
	end
	// Add alu, fpu and condition flags.
	gpu_alu ga(.opc(opcode), .in1(inst1), .in2(inst2), .out()); // opcodes 0 - 13
	gpu_fpu gf(.opc(opcode), .in1(inst1), .in2(inst2), .out()); // opcodes 14 - 22
	gpu_conditional_unit gcu(.opc(opcode), .in1(inst1), .in2(inst2), .out()); // opcodes 23 - 27 
	always@(posedge clk) begin
		$display("gpu_thread1");
		run <= 0; 
		// Every time that one of the opcodes fits into one 
		// of the if statements then turn on the bit in the run vector.
		if ( 0 <= opcode <= 13) begin
		
		end
		if ( 14 <= opcode <= 22) begin
			
		end
		if ( 23 <= opcode <= 27) begin
		
		end
	end
endmodule