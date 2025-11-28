module gpu_conditional_unit(
	input wire [5:0] opc,
	input wire [32:0] in1, 
	input wire [32:0] in2, 
	output wire [32:0] out
	);
	if (opc == 23) begin // equal
		
	end
	if (opc == 24) begin // greater
	end
	if (opc == 25) begin // less
	end
	if (opc == 26) begin // greater equal
	end
	if (opc == 27) begin // less equal 
	end
endmodule