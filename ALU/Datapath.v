module datapath #(											// Instantiated by CPU
	parameter WIDTH = 16, 									// Used by pc_counter, flopr, flopenr, regfile, mux2, mux4, alu_rf, instruction_reg, 
	parameter ALU_CONT_BITS = 6, 							// Used by alu_rf
	parameter REG_BITS = 4, 								// Used by regfile and instruction_reg
	parameter OP_CODE_BITS = 4, 							// Used by instruction_reg
	parameter EXT_OP_CODE_BITS = 4) (					// Used by instruction_reg
	
	input 	clk, 												// Used by pc_counter, flopenr, flopr, regfile, instruction_reg
	input 	reset, 											// Used by pc_counter, flopenr, flopr, alu_rf, instruction_reg
	input		reg_write, 										// Used by regfile
	input		alu_A_src, 										// Used as input into alu_A_mux
	input		alu_B_src,										// Used as input into alu_B_mux
	input		pc_en, 											// Used in pc_flopenr
	input		loading, 										// Used to decide what address to access in memory
	input		storing, 										// See above
	input		instruction_en,								// Used by instruction_en
	input		[1 : 0] pc_src, 								// Used as input into pc_src_mux
	input 	[1 : 0] reg_write_src,						// Used as input into reg_write_src_mux
	input		[ALU_CONT_BITS - 1 : 0]	alu_cont,		// Used by alu_rf
	input 	[WIDTH - 1:0] data_from_mem,				// Used by reg_write_src_mux and instruction_reg
	
	output	[OP_CODE_BITS - 1 : 0] op_code, 			// Output by instruction_reg
	output 	[EXT_OP_CODE_BITS - 1 : 0] ext_op_code,// See above
	output 	[REG_BITS - 1 : 0] A_index, 				// Output by instruction_reg also input to regfile
	output	[REG_BITS - 1 : 0] B_index,				// Output by instruction_reg also input to regfile
	output 	[WIDTH - 1:0] mem_address, 				// Set to either value in register B or the program counter
	output 	[WIDTH - 1:0] psr_flags, 					// Output by alu_rf
	output 	[WIDTH - 1:0] data_to_mem_store			// Set to reg_A if storing. 
	);
	
	// Multi bit variables (aka wires)
	wire 		[WIDTH - 1 : 0] alu_A_in;					// Comes from alu_A_mux and goes to alu_rf
	wire 		[WIDTH - 1 : 0] alu_B_in;					// Comes from alu_B_mux and goes to alu_rf
	wire 		[WIDTH - 1 : 0] alu_out;					// Comes from alu_rf and goes to pc_src_mux and reg_write_src_mux
	wire 		[WIDTH - 1 : 0] reg_A;						// Comes from reg_A_flopr and goes to alu_A_mux and data_to_mem_store
	wire 		[WIDTH - 1 : 0] reg_B;						// Comes from reg_B_flopr and goes to alu_B_mux, pc_src_mux, and mem_address
	wire 		[WIDTH - 1 : 0] reg_pc;						// Comes from pc_flopenr and goes to pc_counter and alu_A_mux
	wire 		[WIDTH - 1 : 0] file_reg_write_data;	// Comes from reg_write_src_mux and goes to regfile.
	wire 		[WIDTH - 1 : 0] A_data;						// Comes from regfile and goes to reg_A_flopr
	wire 		[WIDTH - 1 : 0] B_data; 					// Comes from regfile and goes to reg_B_flopr
	wire 		[WIDTH - 1 : 0] immediate_from_ins_reg;// Comes from instruction_reg and goes to alu_B_mux
	wire 		[WIDTH - 1 : 0] next_pc;					// Comes from pc_src_mux and goes to pc_flopenr
	wire 		[WIDTH - 1 : 0] incremented_pc;			// Comes from pc_counter and goes to reg_write_src_mux and pc_src_mux
		
	assign data_to_mem_store = storing ? reg_A : 1'b0;
	assign mem_address = (loading || storing) ? reg_B : reg_pc;
	
	// Incrementer by one for program counter
	pc_counter #(WIDTH)
	pc_counter(
		.clk(clk),												// Input: clock signal
		.reset(reset),											// Input: resets incremented_pc to zero
		.current_pc(reg_pc),									// Input: Current state of program counter
		.incremented_pc(incremented_pc)					// Output: incremented program counter, by one
	);
	
	// Program counter register
	flopenr #(WIDTH)
	pc_flopenr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: Resets q to 0
		.en(pc_en),											// Input: Allow writing d to q?
		.d(next_pc),										// Input: next address to put in program counter on next CPU cycle
		.q(reg_pc)											// Output: stored address from last CPU cycle until updated on rising clock edge
	);
	 
	// Register file
	regfile #(WIDTH, REG_BITS) 
	regfile(
		.clk(clk), 											// Input: clock signal
		.reg_write(reg_write), 							// Input: write register A to register file?
		.A_index(A_index),								// Input: access which register? (1-15), 0 reserved
		.B_index(B_index),								// Input: see above
		.write_data(file_reg_write_data),			// Input: what data to write to register A
		.A_data(A_data), 									// Output: data stored in register A
		.B_data(B_data)									// Output: data stored in register B
	);
	
	// A register, not any of the numbered registers
	flopr #(WIDTH)
	reg_A_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset q to zero
		.d(A_data),											// Input: next value from registerfile output A to store in reg_A
		.q(reg_A)											// Output: current reg_A value
	);
	
	// B register, not any of the numbered registers
	flopr #(WIDTH)
	reg_B_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset q to zeor
		.d(B_data),											// Input: next value from registerfile output B to store in reg_B
		.q(reg_B)											// Output: current reg_B value, also is an output of datapath
	);
	
	// ALU A input mux, 
	// 0 for branch displacement using the program counter, 
	// 1 for data from register file output A
	mux2 #(WIDTH)
	alu_A_mux(
		.selection(alu_A_src),							// Input: alu_A_src determines which is used for ALU A input
		.input_1(reg_pc),									// Input: data from program counter register
		.input_2(reg_A),									// Input: data from register A
		.mux2_output(alu_A_in)							// Output: I guess I decided to output one f em
	);
	
	// ALU B input mux, 
	// 0 for data from register file output B, 
	// 1 for immediate value from instruction
	mux2 #(WIDTH)
	alu_B_mux(
		.selection(alu_B_src),							// Input: see above, alu_A_mux
		.input_1(reg_B),									// Input:
		.input_2(immediate_from_ins_reg),			// Input:
		.mux2_output(alu_B_in)							// Output:
	);
	
	// PC source mux, DEFAULT IS 2, INCREMENT BY ONE
	// 0 for result from ALU by adding an immediate
	// 1 for value (presumably an address) from register B
	// 2 for incrementeing by one, separate from alu
	// 3 null
	mux4 #(WIDTH)
	pc_src_mux(
		.selection(pc_src),								// Input: pc_src determines how next program counter address is used
		.input_1(alu_out),								// Input: instantaneous output from alu
		.input_2(reg_B),									// Input: data from register B
		.input_3(incremented_pc),						// Input: data from incremented pc
		.input_4(),											// null
		.mux4_output(next_pc)							// Output: set next_pc variable
	);
		
	// Register file write source mux, 
	// 0 for writing the value from the alu into reg a
	// 1 for writing the value from memory into reg A
	// 2 for writing the incremented program counter to register A, used for JAL
	mux4 #(WIDTH)
	reg_write_src_mux(
		.selection(reg_write_src),						// Input: Same basic idea as pc_src_mux but for setting wht value is written to reg A
		.input_1(alu_out),								// Input:
		.input_2(data_from_mem),						// Input:
		.input_3(incremented_pc),						// Input:
		.input_4(),											// Just here so no warnings show up.
		.mux4_output(file_reg_write_data)			// Output:
	);
	
	
	// ALU unit
	alu_rf #(WIDTH, ALU_CONT_BITS) 	
	alu_rf(
		.reset(reset),
		.a(alu_A_in), 										// Input: source for first value in alu
		.b(alu_B_in), 										// Input: second source for alu
		.alu_cont(alu_cont),								// Input: what operation to complete
		.alu_out(alu_out), 								// Output: resulting value from completed operation on two input values
		.psr_flags(psr_flags)							// Output: what flags were set
	);
	
	// Instruction register
	instruction_reg #(WIDTH, REG_BITS, OP_CODE_BITS, EXT_OP_CODE_BITS)
	instruction_reg(
		.clk(clk),
		.reset(reset),
		.instruction_en(instruction_en),
		.input_instruction(data_from_mem),			// Input: raw assembly instruction
		.op_code(op_code),								// Output: bits 15 - 12 of instruction
		.ext_op_code(ext_op_code),						// Output: bits 7 - 4 of instruction
		.immediate_value(immediate_from_ins_reg),	// Output: oof, probably need to rework this. bits 7 - 0 I think
		.A_index_out(A_index), 							// Output: bits 11 - 8 of instruction
		.B_index_out(B_index)							// Output: bits 3 - 0 of instruction
	);
	
endmodule
