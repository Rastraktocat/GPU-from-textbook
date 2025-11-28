The code is being modified heavily right now as I am still learning how to implement all the gpu techniques. 

Right now the testbench doesn't work as it should and all the code stops before it can be made to do anything (everything else compiles and then the code either reaches the finish statement or doesn't and the runtime engine never stops). 

I trying to implement banking, score boarding, caching, operand collection, simt and simd. 

Notable decision --

The pc (program counter) is intended to be controlled by gpu.v/gpu_tb.v so that jumping can be done easily. 

gpu_warp.v is meant to handle gpu scheduling but I am unsure of how I am going to handle it in terms of hardware scheduling / software scheduling techniques.

gpu_memory.v takes care of both reading/writing from registers/banks and from cache. I currently have no idea how big the cache is going to be but I know I am trying to have L1 and L2 cache. 

gpu_warp.v currently reads opcodes and decodes them. For that reason gpu_alu.v, gpu_fpu.v, and gpu_conditional_unit.v are being replaced.

Operand collection, scoreboarding, and simd are not at all done yet. I am working on simt, caching and banking however they are not at all in a decent state.