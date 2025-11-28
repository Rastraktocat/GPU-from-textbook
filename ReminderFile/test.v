module test(
	input wire x, // Notice that the inputs are all wire. Input cannot be declared as a reg.
	input wire y,
	output wire z // Notice that z is declared as a wire.
	);
	assign z = x + y; // The assign keyword is used so that variables that are declared as wires are constantly updated.
endmodule
// The command line is in icarus verilog. They are listed below in order of how they were input.
// iverilog -o test.vvp test.v test_tb.v
// vvp test.vvp
// gtkwave test.vcd
// In gtkwave you click on the module under sst. Then you click the signal and insert.