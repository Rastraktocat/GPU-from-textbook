module gpu_tb;

 logic mem; 
    // this is for simulating fetching
    // instructions. Size - 2+4+32+128

    initial begin
        // fopen is for debugging
        // readmemh is for sysverilog
        $readmemh("instruction.txt", mem);
        
        // the operand size | made of 2 bits
        // 00 is 8 bits | 01 is 16 bits
        // 10 is 32 bits | 11 is 64 bits

        // the addressing mode made of 2
        // bit each 4 bits normally 
        // THE FIRST OPERAND CANNOT
        // BE AN IMMEDIATE.
        // 0 is immediate | 1 is register
        // 2 is memory address

        // assume for now 32 bit opcodes.

        // the actual operand | 64 bits each
        // 128 bits in total
    end

endmodule 