module gpu_fpu(
	input wire [5:0] opc,
	input wire [32:0] in1, //handle IEEE 742 floating point numbers.
	input wire [32:0] in2, 
	output wire [32:0] out
	);
	if (opc == 14) begin // make adding floats work.
		assign out = in1 + in2; 
	end
	if (opc == 15) begin
		assign out = in1 - in2;
	end
	if (opc == 16) begin
		assign out = in1 * in2;
	end
	if (opc == 17) begin
		assign out = in1 / in2;
	end
	if (opc == 18) begin // square root. 
	end
	if (opc == 19) begin // sin
	end
	if (opc == 20) begin // cos
	end
	if (opc == 21) begin // tan
	end
	if (opc == 22) begin // log
	end
endmodule