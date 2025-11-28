`timescale 1ps/1ps // There was a problem with the timescaling for 1ns/1ps. (every instruction happened every 4000 ps. 
module test_tb;
	reg a; // Notice how the first variable in the test file 
	// was a wire type. You cannot manipulate a wire in an
	// initial block. 
	reg b;
	wire c;
	test tst(.x(a), .y(b), .z(c)); 
	// This is the instantiation of the previous test file.
	// The .x, .y, and .z are the ports of the previous test file.
	// When instantiating using ports is recommended. Do note that 
	// they require that you know the exact name of the input variable.
	
	initial begin 
		$dumpfile("test.vcd"); 
		// I am not sure if this icarus verilog specific.
		// A .vcd file is meant to be the input of a gtkwave ( The wave form generator
		// Icarus Verilog uses. )
		
		$dumpvars(0, test_tb); 
		// This is telling Icarus Verilog to dump the variables into 
		// the vcd file. $dumpvars(level, scope) is the default thing.
		// You would input level as a number. 0 for example is the variables
		// in the instance. 1 dumps variables in the module and associated 
		// intialized variables. I don't know how two does things. scope is the 
		// module or instance that you are looking at.
		
		a = 1; b = 1; // This initializes the variables as zero.
		
		#2 
		a = 1; b = 1; // The "#" operator tells the sim to wait
		// for however much time you specify. We are changing the varibles
		// to have different values as of this moment.
		#2 
		a = 0; b = 0;
		#2 
		a = 0; b = 1;
		#2 
		a = 1; b = 0;
		#200
		$finish; // $finish just finishes the gtkwave simulation.
	end 
	// Whenever doing anything with a keyword in Icarus Verilog make sure 
	//that you have a begin and end block. 
		
endmodule // You need an endmodule after every module.