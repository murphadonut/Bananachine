module CPU #(parameter WIDTH = 16, REG_BITS = 4, OP_CODE_BITS = 4, EXT_OP_CODE_BITS = 4, ALU_CONT_BITS = 6)(
	input 	clk, reset,
	input 	[WIDTH - 1 : 0] data_from_mem,
	output 	write_to_memory, reading_for_load,
	output 	[WIDTH - 1 : 0] mem_address, data_to_mem_store
	);
	
	
	wire alu_A_src, alu_B_src, reg_write, pc_en, loading, storing, instruction_en;
	wire [1 : 0] pc_src, reg_write_src;
	wire [ALU_CONT_BITS - 1 : 0] alu_cont;
	wire [OP_CODE_BITS - 1 : 0] op_code;
	wire [EXT_OP_CODE_BITS - 1 : 0] ext_op_code;
	wire [REG_BITS - 1 : 0] A_index, B_index;
	wire [WIDTH - 1 : 0] psr_flags;
	
	assign reading_for_load = loading;
	
	
	controller #(WIDTH, ALU_CONT_BITS, REG_BITS, OP_CODE_BITS, EXT_OP_CODE_BITS)
	cont(
		.clk(clk),
		.reset(reset),
		.op_code(op_code),
		.ext_op_code(ext_op_code), 
		.A_index(A_index), 
		.B_index(B_index),
		.psr_flags(psr_flags),						// Input
		.alu_A_src(alu_A_src),						// Output
		.alu_B_src(alu_B_src), 
		.reg_write(reg_write), 
		.write_to_memory(write_to_memory),
		.pc_en(pc_en),
		.loading(loading),
		.storing(storing),
		.instruction_en(instruction_en),
		.pc_src(pc_src), 
		.reg_write_src(reg_write_src),
		.alu_cont(alu_cont)
	);
	
	datapath #(WIDTH, ALU_CONT_BITS, REG_BITS, OP_CODE_BITS, EXT_OP_CODE_BITS)
	dp(
		.clk(clk),
		.reset(reset),
		.reg_write(reg_write),
		.alu_A_src(alu_A_src), 
		.alu_B_src(alu_B_src),
		.pc_en(pc_en),
		.loading(loading),
		.storing(storing),
		.instruction_en(instruction_en),
		.pc_src(pc_src), 
		.reg_write_src(reg_write_src),
		.alu_cont(alu_cont),
		.data_from_mem(data_from_mem),
		.op_code(op_code), 
		.ext_op_code(ext_op_code),
		.A_index(A_index),
		.B_index(B_index),
		.mem_address(mem_address), 	
		.psr_flags(psr_flags), 
		.data_to_mem_store(data_to_mem_store)
	);
	
endmodule
