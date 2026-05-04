package gpu_structs;

    typedef enum logic {
        THREAD_AT_BARRIER,
        THREAD_READY
    } thread_state_enum_t;    
    // size subject to change.
    // Signifies whether a thread is ready to execute, 
    // blocked at a convergence barrier (specify which), 
    // or has yielded. 

    typedef struct packed {
        logic [1:0] warp_operand_size1;
        logic [1:0] warp_operand_size2;
        // the operand size | made of 2 bits
        // 00 is 8 bits | 01 is 16 bits
        // 10 is 32 bits | 11 is 64 bits 
        logic [1:0] warp_addressing_mode1;
        logic [1:0] warp_addressing_mode2;
        // the addressing mode made of 2
        // bit each 4 bits normally 
        // THE FIRST OPERAND CANNOT 
        // BE AN IMMEDIATE.
        // 0 is immediate | 1 is register
        // 2 is memory address
        logic [4:0] warp_opcode;
        // assume for now 5 bit opcodes.
        logic [63:0] warp_operand1;
        logic [63:0] warp_operand2;
        // the actual operand | 64 bits each
        // 128 bits in total
    } single_warp_inst_t;

    typedef struct packed {
        logic [63:0] pc0;
        logic [63:0] pc1;
        logic [63:0] pc2;
        logic [63:0] pc3;
    } all_warp_pc_t;

    typedef enum logic [1:0] {
        WARP_READY,
        WARP_WAITING,
        WARP_DONE
    } warp_scheduling_enum_t;

    typedef struct packed {
        warp_scheduling_enum_t warp0_status;
        warp_scheduling_enum_t warp1_status;
        warp_scheduling_enum_t warp2_status;
        warp_scheduling_enum_t warp3_status;
    } warp_scheduling_status_t;

endpackage : gpu_structs