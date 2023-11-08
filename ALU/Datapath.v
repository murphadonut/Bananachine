module datapath #(parameter WIDTH = 16, ALU_CONT_BITS = 6, REG_BITS = 4, OP_CODE_BITS = 4, EXT_OP_CODE_BITS = 4)(

	input 	clk, reset, reg_write, alu_A_src, alu_B_src,	pc_en, loading, storing, instruction_en,
	input		[1 : 0] 						pc_src, reg_write_src,
	input		[ALU_CONT_BITS - 1 : 0]	alu_cont,
	input 	[WIDTH - 1:0] 				data_from_mem,
	
	output 	[OP_CODE_BITS - 1 : 0] op_code, 
	output 	[EXT_OP_CODE_BITS - 1 : 0] ext_op_code,
	output 	[REG_BITS - 1 : 0] A_index, B_index,
	output 	[WIDTH - 1:0] 		mem_address, psr_flags, data_to_mem_store
	);
	
	// Multi bit variables (aka wires)
	wire [WIDTH - 1 : 0]
		alu_A_in,
		alu_B_in,
		alu_out,
		reg_A,					// Output of a flopr
		reg_B,					// Output of a flopr
		reg_pc,					// Output of a flopr
		file_reg_write_data,
		A_data, 
		B_data, 
		immediate_from_ins_reg,
		next_pc,
		incremented_pc;
		
	assign data_to_mem_store = storing ? reg_A : 1'b0;
	assign mem_address = (loading || storing) ? reg_B : reg_pc;
	
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
		.en(pc_en),
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
		.input_2(immediate_from_ins_reg),//reg_immediate),						// Input, got rid of reg_immediate
		.mux2_output(alu_B_in)							// Output
	);
	
	// PC source mux, DEFAULT IS 2, INCREMENT BY ONE
	// 0 for result from ALU by adding an immediate
	// 1 for value (presumably an address) from register B
	// 2 for incrementeing by one, separate from alu
	// 3 null
	mux4 #(WIDTH)
	pc_src_mux(
		.selection(pc_src),								// Input: see alu_A_mux for stupid descriptions of these
		.input_1(alu_out),//reg_alu),								// Input
		.input_2(reg_B),									// Input
		.input_3(incremented_pc),						// Input
		.input_4(),											// for reset
		.mux4_output(next_pc)							// Output
	);
		
	// Register file write source mux, 
	// 0 for writing the value from the alu into reg a
	// 1 for writing the value from memory into reg A
	// 2 for writing the incremented program counter to register A, used for JAL
	mux4 #(WIDTH)
	reg_write_src_mux(
		.selection(reg_write_src),						// Input: see alu_A_mux for stupid descriptions of these
		.input_1(alu_out),//reg_alu),					// Input
		.input_2(data_from_mem),					// Input
		.input_3(incremented_pc),						// Input
		.input_4(),											// Just here so no warnings show up.
		.mux4_output(file_reg_write_data)			// Output
	);
	
	
	// ALU unit
	alu_rf #(WIDTH, ALU_CONT_BITS) 	
	alu_unit(
		.reset(reset),
		.a(alu_A_in), 										// Input: source for first value in alu
		.b(alu_B_in), 										// Input: second source for alu
		.alu_cont(alu_cont),								// Input: what operation to complete
		.alu_out(alu_out), 								// Output: resulting value from completed operation on two input values
		.psr_flags(psr_flags)							// Output: what flags were set
	);
	
	// Instruction register
	instruction_reg #(WIDTH, REG_BITS, OP_CODE_BITS, EXT_OP_CODE_BITS)
	ins_reg(
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
