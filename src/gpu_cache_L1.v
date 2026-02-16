module gpu_cache(
	input wire clk,
	input wire in_tag,
	input wire [12:0] in_request, 
	output reg cache_hit_or_miss,
	output reg [255:0] out,
	output reg [2:0]prt_out[0:12] //assuming the tag size is 13 bits. 
	);
	
	// This cache is set-associative. x sets. 
	// y tags per set. Each data has 256 bits. 
	

	// The cache will be made up of x number of sets. 
	// The tag and data will be two different arrays 
	// in an unpacked array in sysverilog. 

	reg [12:0] cache [0:31]; 
	// All data is gotten at once.

	reg [12:0] prt [0:11]; 
	reg [2:0] prt_size; 
	// the prt will have 6 entries. 
	// each entry will have x size per tag. 

	reg hit_or_miss;
	integer i;
	integer j;

	always@(posedge clk) begin
		// If we cannot handle a cache miss 
		// we will reject the cache
		//  won't even interpret it. 
		if (prt_size != 6) begin
			for (i = 0; i < 16; i = i + 1) begin
				if (hit_or_miss == 0) begin
					// This could be done very easily with variable 
					// indexing. 

					// You would just need to compare the in_request
					// to all of the y tags. If there is a hit then 
					// you set it as a hit and move the data to out. 

					if () begin // the condition would be 
					// the table full of tags in the set.

						hit_or_mass = 1;
						out = data; 

					end
				end
			end

			cache_hit_or_miss = hit_or_miss;

			if (hit_or_miss == 0) begin
				for (j = 0; j < 6; j = j + 1) begin
					// This could only be done 
					// in sysverilog because of
					// the variable indexing. 
					if (prt[i] == 0) begin
						prt[i] = in_request;
					end
				end
				prt_size = prt_size + 1;
			end
		end
	end
endmodule