// notes
// we dont have a single bit input called IorD like the minimips, 
// pc_en may be useless
// dont have single bit input called regdst
// no irwrite, pretty sure this was for loading shit in four cycles instead of one
// no zero detection stuff


module datapath #(parameter WIDTH = 16, REG_BITS = 5, ALU_CONT_BITS = 5, IMM_BITS = 8, OP_BITS = 4)(

	// Single bit inputs
	input 	
		reg_write, 
		clk, 
		reset, 
		pc_en, 
		alu_A_src,
		pc_src,
		reg_write_src,
		destination_reg,
		
	// Multi bit inputs
	input		[1 : 0] alu_B_src,
	input		[ALU_CONT_BITS - 1 : 0]	alu_cont,
	input 	[WIDTH - 1:0] 
		instruction, 
		data_from_mem,			// data from memory access
	
	// OUTPUTUs
	output 	[WIDTH - 1:0] 	
		pc, 						// This will hold the address for the next instruction
		psr_flags, 
		data_to_mem 			// data from B register
	);
	
	// Multi bit variables (aka wires)
	wire [WIDTH - 1 : 0]
		alu_A_in,
		alu_B_in,
		alu_out,
		reg_alu,					// Output of a flopr
		reg_A,					// Output of a flopr
		reg_B,					// Output of a flopr
		reg_mdr,					// Output of a flopr
		reg_immediate,			// Output of a flopr
		file_reg_write_data,
		A_data, 
		B_data, 
		A_index, 
		B_index, 
		write_index,
		immediate_from_ins_reg,
		next_pc;
		
	assign data_to_mem = reg_B;
	
	
	// Program counter register
	// may not need the enable part
	flopenr #(WIDTH)
	pc_flopenr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.en(pc_en),											// Input: enable pc flip flop, also may be useless
		.d(next_pc),										// Input: next address to put in program counter on next CPU cycle
		.q(pc)												// Output: stored address from last CPU cycle
	);
	 
	// Register file
	regfile #(WIDTH, REG_BITS) 
	reg_file(
		.clk(clk), 											// Input: clock signal
		.reg_write(reg_write), 							// Input: write register A to register file?
		.A_index(A_index),								// Input: access which register? (1-15), 0 reserved
		.B_index(B_index),								// Input: see above
		.write_index(write_index),
		.write_data(file_reg_write_data),			// Input: what data to write to register A
		.A_data(A_data), 									// Output: data stored in register A
		.B_data(B_data)									// Output: data stored in register B
	);

	// Immediate data register
	flopr #(WIDTH)
	immediate_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(immediate_from_ins_reg),					// Input: next immediate value to store in immediate_out
		.q(reg_immediate)									// Output: current immediate value, stored
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
	
	// Memory data register, this holds data from input memory
	flopr #(WIDTH)
	mdr_flopr(
		.clk(clk),											// Input: clock signal
		.reset(reset),										// Input: reset flip flop, might not be needed
		.d(data_from_mem),								// Input: datapath input, from memory
		.q(reg_mdr)											// Output: current value of memory data register
	);
	
	// Input address mux for memory
	mux2 #(WIDTH)
	address_mux(
		.selection(destination_reg),
		.input_1(A_index),
		.input_2(B_index),
		.mux2_output(write_index)
	);
	
	// ALU A input mux, 
	// 0 for branch displacement using the program counter, 
	// 1 for data from register file output A
	mux2 #(WIDTH)
	alu_A_mux(
		.selection(alu_A_src),							// Input: what do I send through this here mux?
		.input_1(pc),										// Input: do I send this? input 0??
		.input_2(reg_A),									// Input: or do I send this little fella, input 1??
		.mux2_output(alu_A_in)							// Output: I guess I decided to output one f em
	);
	
	// ALU B input mux, 
	// 0 for data from register file output B, 
	// 1 for immediate value from instruction
	// 2 for hardcoded one, used for pc increment
	mux4 #(WIDTH)
	alu_B_mux(
		.selection(alu_B_src),							// Input: see alu_A_mux for stupid descriptions of these
		.input_1(reg_B),									// Input
		.input_2(reg_immediate),						// Input
		.input_3(1'b1),									// Input
		.mux4_output(alu_B_in)							// Output
	);
	
	// PC source mux, 
	// 0 for result from ALU, either incrementing by one or adding an immediate
	// 1 for value (presumably an address) from register B
	mux2 #(WIDTH)
	pc_src_mux(
		.selection(pc_src),								// Input: see alu_A_mux for stupid descriptions of these
		.input_1(reg_alu),								// Input
		.input_2(reg_B),									// Input
		.mux2_output(next_pc)							// Output
	);
		
	// Register file write source mux, 
	// 0 for writing the value from the alu into register A
	// 1 for writing the value from memory into register A
	mux2 #(WIDTH)
	reg_write_src_mux(
		.selection(reg_write_src),						// Input: see alu_A_mux for stupid descriptions of these
		.input_1(reg_alu),								// Input
		.input_2(reg_mdr),								// Input
		.mux2_output(file_reg_write_data)			// Output
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
		.input_instruction(instruction),				// Input: raw assembly instruction
		.op_code(),											// Output: bits 15 - 12 of instruction
		.ext_op_code(),									// Output: bits 7 - 4 of instruction
		.immediate_value(immediate_from_ins_reg),	// Output: oof, probably need to rework this. bits 7 - 0 I think
		.A_index_out(A_index), 							// Output: bits 11 - 8 of instruction
		.B_index_out(B_index)							// Output: bits 3 - 0 of instruction
	);
	
endmodule
