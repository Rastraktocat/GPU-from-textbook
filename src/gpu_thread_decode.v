module gpu_thread_decode(
	input wire clk,
	input wire address_1,
	input wire address_2,
	input wire mem_in1,
	input wire mem_in2,
	output wire mem_out1,
	output wire mem_out2
	);
	
	integer i;
	
	always@( posedge clk ) begin
		if (address_1 == 0) begin // intermediate message

		end
		if (address_1 == 1) begin // register

		end
		if (address_1 > 1) begin // figure out offsets
		// for memory addresses. 

		end
		if (mem_in1 != 0) begin
		
		end
		if (mem_in2 != 0) begin
		end
	end
endmodule