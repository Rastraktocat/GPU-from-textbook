module gpu_bank(
	input wire clk,
	input wire read_bank,
	input wire write_bank,
	input wire [63:0] in [0:31],
	input wire [1:0] bank_warp_num,
	output wire [63:0] out [0:31]
	); // This may be subject to change if I learn how to do this better.
	
	reg [2047:0] bank_contents[0:3]; // FIX EVERYTHING!!!
	// 32 lane 32 banks representing 8 64-bit 32-register register files in 8x4 configuration.
	
	integer i;
	reg [31:0] bank_current;
	reg [63:0] bank_out [0:31];
	reg [1:0] taken_lane [0:3];
	
	always@(posedge clk) begin
		if (read_bank) begin
			for (i = 0; i < 32; i = i + 1) begin : loop
				bank_current <= in_read[i*32:i*32+32]; // fix this. 
				if (bank_current != ) begin // for if the register is skipped. 
					
					if (taken_lane[bank_warp_num][] == 0) begin
						
					end
				end
			end
		end
		if (write_bank) begin
			
		end
	end
endmodule