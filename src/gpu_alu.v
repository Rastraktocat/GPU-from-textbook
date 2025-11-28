module gpu_alu(
	input wire [5:0] opc, // make appropriate size.
	input wire [31:0] in1, 
	input wire [31:0] in2, 
	output wire [31:0] out,
	output wire z_flag,
	output wire s_flag, 
	output wire o_flag,
	output wire c_flag
	);
	wire [31:0] carry;
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
endmodule