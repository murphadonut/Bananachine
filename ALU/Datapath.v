module datapath #(parameter WIDTH = 16, REG_BITS = 4, ALU_CONT_BITS = 6, IMM_BITS = 8, OP_BITS = 4)(

	input 	clk, reset, reg_write, alu_A_src, alu_B_src,			
	input		[1 : 0] 						pc_src, reg_write_src,
	input		[ALU_CONT_BITS - 1 : 0]	alu_cont,
	input 	[WIDTH - 1:0] 				data_from_mem_PC, data_from_mem_load,
	
	output	zero,
	output 	[OP_BITS - 1 : 0] op_code, ext_op_code, A_index, B_index, 
	output 	[WIDTH - 1:0] 		mem_address_PC, mem_address_load_stor,	psr_flags, data_to_mem_stor
	);
	
	// Multi bit variables (aka wires)
	wire [WIDTH - 1 : 0]
		alu_A_in,
		alu_B_in,
		alu_out,
		reg_alu,					// Output of a flopr
		reg_A,					// Output of a flopr
		reg_B,					// Output of a flopr
		reg_mdr_PC,				// Output of a flopr
		reg_mdr_load,
		reg_immediate,			// Output of a flopr
		reg_pc,					// Output of a flopr
		file_reg_write_data,
		A_data, 
		B_data, 
		immediate_from_ins_reg,
		next_pc,
		incremented_pc;
		
	assign data_to_mem_stor = reg_A;
	assign mem_address_PC = reg_pc;
	assign mem_address_load_stor = reg_B;
	
	// Zero detect, we don't know why this needed yet
	zerodetect #(WIDTH)
	zero_thingy(
		.a(alu_out),										// Input
		.y(zero)												// Output
	);
	
	// Incrementer by one for program counter
	pc_counter #(WIDTH)
	counter(
		.clk(clk),											// Input
		.reset(reset),										// Input
		.current_pc(reg_pc),								// Input
		.incremented_pc(incremented_pc)				// Output
	);
	
	// Program counter register
	flopenr #(WIDTH)
	pc_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop
		.d(next_pc),										// Input: next address to put in program counter on next CPU cycle
		.q(reg_pc)											// Output: stored address from last CPU cycle
	);
	 
	// Register file
	regfile #(WIDTH, REG_BITS) 
	reg_file(
		.clk(clk), 											// Input: clock signal
		.reg_write(reg_write), 							// Input: write register A to register file?
		.A_index(A_index),								// Input: access which register? (1-15), 0 reserved
		.B_index(B_index),								// Input: see above
		.write_data(file_reg_write_data),			// Input: what data to write to register A
		.A_data(A_data), 									// Output: data stored in register A
		.B_data(B_data)									// Output: data stored in register B
	);

	// does this need to be a register?
	// Immediate data register
	flopr #(WIDTH)
	immediate_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(immediate_from_ins_reg),					// Input: next immediate value to store in immediate_out
		.q(reg_mmediate)									// Output: current immediate value, stored
	);
	
	// A register, not any of the numbered registers
	flopr #(WIDTH)
	reg_A_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(A_data),											// Input: next value from registerfile output A to store in reg_A
		.q(reg_A)											// Output: current reg_A value
	);
	
	// B register, not any of the numbered registers
	flopr #(WIDTH)
	reg_B_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(B_data),											// Input: next value from registerfile output B to store in reg_B
		.q(reg_B)											// Output: current reg_B value, also is an output of datapath
	);
	
	// ALU register, alu result goes into here where its synced with the clock or something like that
	flopr #(WIDTH)
	reg_alu_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(alu_out),										// Input: output value from alu
		.q(reg_alu)											// Output: stored alu value
	);
	
	// Memory data register, this holds the returned data from memory that specifically holds the next instruction from program counter
	flopr #(WIDTH)
	mdr_PC_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(data_from_mem_PC),							// Input: datapath input, from memory
		.q(reg_mdr_PC)										// Output: current value of memory data register
	);
	
	// Memory data register, this holds data from input memory only used for loads
	flopr #(WIDTH)
	mdr_load_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(data_from_mem_load),							// Input: datapath input, from memory
		.q(reg_mdr_load)									// Output: current value of memory data register
	);
	
	// ALU A input mux, 
	// 0 for branch displacement using the program counter, 
	// 1 for data from register file output A
	mux2 #(WIDTH)
	alu_A_mux(
		.selection(alu_A_src),							// Input: what do I send through this here mux?
		.input_1(reg_pc),									// Input: do I send this? input 0??
		.input_2(reg_A),									// Input: or do I send this little fella, input 1??
		.mux2_output(alu_A_in)							// Output: I guess I decided to output one f em
	);
	
	// ALU B input mux, 
	// 0 for data from register file output B, 
	// 1 for immediate value from instruction
	mux2 #(WIDTH)
	alu_B_mux(
		.selection(alu_B_src),							// Input: see alu_A_mux for stupid descriptions of these
		.input_1(reg_B),									// Input
		.input_2(reg_immediate),						// Input
		.mux2_output(alu_B_in)							// Output
	);
	
	// PC source mux, CHANGED FROM B TO A
	// 0 for result from ALU by adding an immediate
	// 1 for value (presumably an address) from register B
	// 2 for incrementeing by one, separate from alu
	mux4 #(WIDTH)
	pc_src_mux(
		.selection(pc_src),								// Input: see alu_A_mux for stupid descriptions of these
		.input_1(reg_alu),								// Input
		.input_2(reg_B),									// Input
		.input_3(incremented_pc),						// Input
		.mux4_output(next_pc)							// Output
	);
		
	// Register file write source mux, 
	// 0 for writing the value from the alu into reg a
	// 1 for writing the value from memory into reg A
	// 2 for writing the incremented program counter to register A, used for JAL
	mux4 #(WIDTH)
	reg_write_src_mux(
		.selection(reg_write_src),						// Input: see alu_A_mux for stupid descriptions of these
		.input_1(reg_alu),								// Input
		.input_2(reg_mdr_load),							// Input
		.input_3(incremented_pc),
		.mux4_output(file_reg_write_data)			// Output
	);
	
	
	// ALU unit
	alu_rf #(WIDTH, ALU_CONT_BITS) 	
	alu_unit(
		.a(alu_A_in), 										// Input: source for first value in alu
		.b(alu_B_in), 										// Input: second source for alu
		.alu_cont(alu_cont),								// Input: what operation to complete
		.alu_out(alu_out), 								// Output: resulting value from completed operation on two input values
		.psr_flags(psr_flags)							// Output: what flags were set
	);
	
	// Instruction register
	instruction_reg #(WIDTH, IMM_BITS, OP_BITS, REG_BITS)
	ins_reg(
		.input_instruction(reg_mdr_PC),				// Input: raw assembly instruction
		.op_code(op_code),								// Output: bits 15 - 12 of instruction
		.ext_op_code(ext_op_code),						// Output: bits 7 - 4 of instruction
		.immediate_value(immediate_from_ins_reg),	// Output: oof, probably need to rework this. bits 7 - 0 I think
		.A_index_out(A_index), 							// Output: bits 11 - 8 of instruction
		.B_index_out(B_index)							// Output: bits 3 - 0 of instruction
	);
	
endmodule
