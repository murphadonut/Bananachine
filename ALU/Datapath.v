module datapath #(parameter WIDTH = 16, REG_BITS = 5, ALU_CONT_BITS = 5, IMM_BITS = 8, OP_BITS = 4)(
	input 	reg_write, clk,  
	input 	[WIDTH - 1:0] 		instruction,
	output 	[WIDTH - 1:0] 		datapath_out, psr_flags//, pc_out
	);

	reg [ALU_CONT_BITS - 1 : 0]	alu_cont;
	//reg [WIDTH - 1:0] 				pc_reg;
	wire [WIDTH - 1:0] 				alu_out, a, b, reg_A_index, reg_B_index;
	
	//assign pc_reg = 
	assign datapath_out = alu_out;	
	
	//mux2 					#(WIDTH) 						pc_reg_mux(a, );
	
	// Register file
	regfile #(WIDTH, REG_BITS) 
	rf(
		.clk(clk), 								// Input
		.reg_write(reg_write), 				// Input
		.reg_A_index(reg_A_index),			// Input
		.reg_B_index(reg_B_index),			// Input
		.reg_write_data(alu_out),			// Input
		.reg_A_storage(a), 					// Output
		.reg_B_storage(b)						// Output
	);
	
	// ALU unit
	alu_rf #(WIDTH, ALU_CONT_BITS) 	
	alu(
		.a(a), 									// Input
		.b(b), 									// Input
		.alu_cont(alu_cont),					// Input
		.alu_out(alu_out), 					// Output
		.psr_flags(psr_flags)				// Output
	);
	
	// Instruction register
	instruction_reg #(WIDTH, IMM_BITS, OP_BITS, REG_BITS)
	ins_reg(
		.input_instruction(instruction),	// Input
		.op_code(),								// Output, needs to go to alu_cont
		.immediate_value(),					// Output
		.reg_A_index(reg_A_index), 		// Output
		.reg_B_index(reg_B_index)			// Output
	);
	
	// 
	
endmodule 
