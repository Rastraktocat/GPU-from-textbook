Before Reading


There is no guarantee all of the information here is 100% true. If I mistakes 
then sorry I was not trying to. 

If you are not a beginner to gpus then you should look in the How to 
run, formatting, functionality and textbook overview for sure. Look in
improvements if you want. Otherwise look at every other section to gain an 
understanding about how gpus work. 

This is currently under testing. Sizeable portions of the codebase have undergone
linting but not everything has been linted. 


Formatting **


 - All variables use _ case.
 - All variables are written in undercase.
 - All variables should be named with a number at the with no _ before it.
 - Variables instantiating a struct or module take first letter of each word 
 in the name and combine them (i.e. word_processor ws)
 - Exceptions to struct naming rule include pc and inst. 
 - Exceptions to the numbering rule include warp0_status, etc. as including the
 number next to the warp part of the variable name increases readability. 

 - When instantiating modules the ports that are passed in are the ones that
 are less complex. For example the actual port will be named warp_inst and
 the passed in port will be named inst (.warp_inst(inst)).

 - All structs contain a _t at the end of their declaration.

 - Space is made to separate variables by functionality. 
 - Blocks (if statements, for loops, etc.) often are separated.

 - Comments are often underneath the thing they are describing. 
 - Comments describing functionality is often put under the ports. 

 - Parameters are all written in uppercase.
 - Otherwise parameters are similar to regular variables.

 ** - the word often is used to specify that there may be cases
where this is not the case due to mistakes. 


Functionality


This is a small gpgpu (gpu) that was designed off of the textbook General Purpose
Graphics Processing Architecture. 


Improvements


 - add scratchpad memory
 - add graphics processing abilities
 - add research pages from the book
 - Make the decode and execute steps comprehensive on the textbook
 overview section.
 - Revise the cache part of the textbook overview section. 
 - Add the floating point alu.
 - Add simd


Textbook Overview 


Like most computers this gpu has a 5 stage. The stages go fetch, decode, 
execute, memory, and writeback. The fetch stage occurs happens when the computer
requests the instruction at the location specified by the program counter*.
The fetched instruction will be sent to all threads* in a warp/wavefront*. This is
called SIMT*. Basically every instruction in a warp/wavefront has the same opcode*
(add, subtract, multiply, etc.) but every thread has different operands*.
(register1, register2, x). 

The decode step "interprets" the signal so that it can be sent to the correct 
place. 

The execute step is the step that does the decoded instruction. 

The gpu generally is supposed to work by taking an input and feeding it to
all threads in its warp (or wavefront) and running them simultaneously. 
If a warp handles a conditional (if statements, while loops, etc.) the threads 
split into to those who take the conditional and those who don't. All threads 
go to a certain point (called the convergence point) and when they do they 
continue to run simulatenously. 

In order to handle accessing registers simulatenously banks are used. Banks
are stacks of register files (themselves just a 2d grid of registers) so that
they can be multiple registers can be accessed at once. These banks are split
into lanes. Each lane can either be read or written from. If a bank has 32 lanes
32 registers can be accessed in that bank. A lane can contain regsiters from 
multiple different register files so they must be arranged effectively. This can 
be understood when a thread asks for register 1. If 1 lane contains every register
1 for all register files then that is really slow. In order to combat this they 
are spread out using a mod 1 fashion where register file 1 will have register 1
on lane 1 and register 2 will have register 1 on lane 2. 

An operand collector is used to make reading/writing from banks as fast as 
possible.

This gpu will only have an L1 and an L2 cache. The L1 cache is the faster and
small cache. In the book there is a regular cache that handles memory addresses.
A gpu will often also have a texture cache that handles the memory that textures
have in video games. 

<Add caching explanation>

Gpus schedule* with warps not processes like a cpu. 

A gpu can context swtich very fast*. It does this so it can hide the latency of 
having a single instruction from a warp take a lot of time. Specifically instead
of waiting for each individual warp to finish getting the memory or register 
information that they need for every thread a different warp can run while the 
instructions for memory and registers can resolve themselves in the background 
while another warp gets its job done. 

We deviate from the textbook when we implement the idea of SMs (streaming
multiprocessor). All that an SM is is a collection of essential components of 
a warp all wrapped together into a single place (I'm not sure to what extent
this is true for all gpus). The gpu itself is currently one SM that is intended
to be instantiated into multiple with a generate for loop if necessary. 

* - Look at the terms are listed under the notable terms section. 


Used Algorithms 


Caching eviction algorithm

Not decided yet.

Cache write algorithm

Not yet decided.

Cache write miss algorithms

Cache lookup algorithm

Hardware scheduling algorithm

Banking algorithm

Warp convergence algorithms


Alternate Algorithms


Caching eviction algorithm
When the cache is full and something needs to be added to the cache.

LRU (Least recently used) - The cache line that hasn't been used for the longest
time gets booted.
LFU (Least freqeuently used) - The item that is used the least amount of times.
FIFO (First In, First Out) - The first item that comes in is the first thing
that comes out. 
LIFO (Last In, First Out) - The first item that comes in is the last thing that 
comes out. This can also be said as the last item that comes in is the first
item out.
Random - Removes a random entry. 

Cache write algorithm
When a value in the cache needs to be written to.

Write-Through - The write goes to both the cache and the disk. 

Write-Back - The write goes to the cache and is updated when it an entry is 
evicted.
Write-Back with dirty bits - Each line has a dirty bit. When there is a 
write only dirty blocks are evicted.
Write-Back with write combining - Holds a bunch of smaller writes together 
then evicts them all at the same time.
Write Coalescing - Holds all of the writes in the same cache line and then
evicts them all at the same time.

Write-Around - The write goes to the disk instead of the cache. 

Cache write miss algorithms
When there is a write and the value is not in the cache.

Write-Allocate (fetch-on-write) - When there is a cache miss the value is brought
into the cache and then updated. 

No-Write-Allocate (Write-No-Allocate) - When there is a cache miss the value is 
written to in disk and the block is not loaded into the cache.

Cache lookup algorithm (For a set associative cache) / Cache miss algorithm

Whenever you want to check if a value is in a cache then you give it an input that
you want to check. That input is split into a tag, index, and offset. The tag
is the upper bytes of the input. The index is the middle bits and the offset 
is the lower bytes. The index is used to determine which set is to be looked at. 
Every tag in the chosen set is compared to the tag of the input and if there is 
a hit then the offset of the tag is chosen to specify which of the memory 
locations in the cache line to give. If there is no tag in the set then there is 
a cache miss and the entry is sent to page request table (prt). Every time the 
gpu records a cache miss to see if there is a request already. If there isn't
an entry in the prt then one is added. When the data returns the prt entry 
is thrown out and the cache returns a cache hit.

Hardware scheduling algorithm

Round Robin - All ready warps are given a turn. After an arbitrary amount of 
time the scheduler would context switch to another warp.

Loose round robin(LRR) - 

Greedy-then-oldest (gto) - The scheduler chooses which whichever warp is running
as long as possible and keeps running it. When a stall happens the oldest ready 
warp is chosen.

Two-level scheduling (tls) - 

Critically-aware scheduling - 

Fair-share scheduling - Makes sure that each warp gets an equal amount of 
compute resources.

Memory-divergence-aware-scheduling - The scheduler prioritizes warps that 
don't have branch divergences as much.

Cache conscious warp scheduling (ccws) - Prioritize warps that are likely to 
get cache hits.

Thread block aware scheduling - 

Banking algorithm

The warp sends a request to a bank and it waits until that request is satisfied.
When it does then the request is sent to a queue. A request on the queue is given
and the bank lines its i/o ports with the registers for the requested bank and
then the request is put into a buffer. If the request is fulfilled immediately 
then the buffer is filled and the request is sent off. If it isn't then the 
request waits until the buffer is full before sending it off. 

Warp Convergence algorithm

IPDOM - The existing implementation that involves the gpu branching until it 
gets to a convergence point.

Stack based convergence - Uses a stack to track things like active mask, pc,
and rPC. 

ITS - Each thread is treated a little bit more independently. 

Thread block compaction /warp compaction - Warps that are taking the same path 
in the same block are run together.

Barrier based convergence - There is explicit synchronization points that
force a reconvergence of the warp/wavefront.


Notable terms 

 Pointer - The C/C++ terminology for a memory address. 
 Program Counter - A pointer for the current instruction to be fetched during
 the fetch stage of the instruction cycle.

 Opcodes - An opcode is the specific identifier for a type of instruction 
 that can be run (i.e. when the opcode is 1 add. when the opcode is 2 subtract).
 Operands - An operand is the data, value or memory address a computer uses
 to do things with. For our purposes they come in the form of the contents 
 of registers, immeadiate values (number like 1, 2, 3,etc.) and memory addresses.

A traditional instruction fetch can compose of 
<opcode> <addressing size> <operand1> <addressing size> <operand2> 

 SIMT - SIMT stands for single input multiple thread. It basically means 
 that every thread will get the same overarching instruction put do it with 
 different operands. 
 SIMD - SIMD stands for single input multiple data. SIMD is the handling of 
 multiple different of the same operation at once. For example you would take
 an array of 16 elements they would be stored in a packed register and then
 the operation would be performed all at once.

 Register - The most used memory element in a computer. There are often general
 registers that are open to the programmer and there are specialized registers
 such as the program counter which is used for one job.
 Sequential logic - Logic that involves an output of a component being fed as 
 its input. You can imagine a simple logic gate where you draw a connection
 between the input and output terminals. It is used to allow a component to
 "remember" the input. This is used in registers.
 Register files - A register file is essentially a 2d grid of registers.
 Banks - A collection of register files that allow for better optimization of
 bank accesses.

 Threads - A thread can be thought of as another computer that shares the same
 memory as a group of computers. A simplified explanation of a computer can
 be thought of as one computer that runs one instruction cycle. A computer with
 multiple threads has a bunch of smaller threads that run their own instruction 
 cycle but share memory regions.
 Instruction cycle - There are many different types of instruction cycles
 however the most simple version of them is a fetch - decode - execute or 3 stage
 cycle. The instruction cycle perpetually runs when the cpu, gpu, etc. starts
 running.
 Context switch - Deciding to let some computer component (in a gpu it would
 be a warp but in a cpu it could be a thread or something else) run instead of 
 the current component.
 Scheduling - Deciding of which component to let run. 
 Warps/Wavefronts - A collection of 32/64 threads that are used to optimize gpus. 

 Cache - A cache is a memory region that is closer to the cpu, gpu, etc. This
 speeds up access to memory.
 Cache hit - When the requested entry is in the cache.
 Cache miss - When the requested entry is not in the cache.
 Frame - A frame is a chunk of main memory that is mapped to the cache.
 Set - A collections of cache lines that map to the same index.
 Cache line - A fixed chunk of bytes that works as an entry in a cache.
 Tag - The identifier for whether a memory block is stored in a cache set.
 Index - The thing that chooses the specific cache set to look up. 
 Offset - Once you have selected a cache line the offset determines which
 possible value you want to get in the line. 


SysVerilog tools used ***


- Packed arrays are used. 
- Queues are used.
- Parameters are used. 
- LocalParams are used. 
- switch/case statements
- generate for loops
- regular for loops
- UVM is used

*** - the syntax for all of these can be seen in the notable syntax section.


SysVerilog tools not used 


Notable syntax ****


Packed arrays - Each bit sits right next to each other.
Unpacked arrays - Represents a more traditional array 

packed syntax
logic [<size>:0] <var>;
logic [<size>:0][<size>:0] <var>; // 2d array
logic [<size>:0][<size>:0][<size>:0] <var>; // 3d array

unpacked syntax
logic <var> [<size>:0]; // 1d array
logic <var> [<size>:0][<size>:0]; // 2d array
logic <var> [<size>:0][<size>:0][<size>:0]; // 3d array

Accessing a packed array syntax
logic <var>[2]; // for the 1d array
logic <var>[2][5]; // for the 2d array

Accessing from an unpacked array
logic <var>[2]; // for the 1d array
logic <var>[2][5]; // for the 2d array

packed+unpacked syntax exist but I don't understand it.


A queue can have a set of number of possible entries or allow as many as you want.
A queue with a set number of entries is bounded and a queue that allows as many
as you want is called an unbounded queue.

Unbounded queue declaration

logic <size_of_entries> <queue_name> [$];

ex. logic [31:0] bounded_queue [$]; // a queue with infinite size.

Bounded queue declaration

logic <size_of_entries> <queue_name> [<num_queue_entries>];

ex. logic [31:0] bounded_queue [$:5]; // a queue of size 6.

Queue api

The queue api consists of 7 methods. Size, Insert, Delete, Push_Front, 
Push_Back, Pop_Front, and Pop_Back. 

To use a method you must append it to <queue_name> with .<method_name>
ex. bounded_queue.size() // returns the number of entries of bounded_queue

size() - Returns the number of entries. 
insert(<index>, <item>) - write an entry at a position. 
delete() - delete every entry in the queue
delete(<index>) - delete the entry at whatever index in the queue.
push_back(<contents_of_entry>) - add the contents of the entry to the first entry
that is not occupied.
push_front(<contents_of_entry>) - add the contents of the entry to the very first 
entry in the queue.
pop_back() - remove the contents of the last entry in the queue.
pop_front() - remove the contents of the first entry in the queue.
shuffle() - shuffles the entries in the queue.

jlj;l;lj;lj;

UVM Explanation

UVM is a SysVerilog based framework that makes testbenches better in order to
verify hardware designs better. UVM exists in phases. There is a build phase which
involves 

**** - Most of these haven't been cross referenced in the code but are instead 
copied from websites showing off the api. That means that I can't confirm if they work properly or not.

