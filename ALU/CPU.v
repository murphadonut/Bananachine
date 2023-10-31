module CPU #(parameter WIDTH = 16, REG_BITS = 4, ALU_CONT_BITS = 6, IMM_BITS = 8, OP_BITS = 4)(
	input clk, reset,
	input [WIDTH - 1 : 0] data_from_mem_PC, data_from_mem_load,
	output write_to_memory,
	output [WIDTH - 1 : 0] mem_address_PC, mem_address_load_stor, data_to_mem_stor
	);
	
	
	wire alu_A_src, alu_B_src, reg_write, pc_en;
	wire [1 : 0] pc_src, reg_write_src;
	wire [ALU_CONT_BITS - 1 : 0] alu_cont;
	wire [OP_BITS - 1 : 0] op_code, ext_op_code, A_index, B_index;
	wire [WIDTH - 1 : 0] psr_flags;
	
	
	controller #(WIDTH, ALU_CONT_BITS, OP_BITS)
	cont(
		.clk(clk),
		.reset(reset),
		.op_code(op_code),
		.ext_op_code(ext_op_code), 
		.A_index(A_index), 
		.B_index(B_index),
		.psr_flags(psr_flags),						// Input
		.pc_en(pc_en),
		.alu_A_src(alu_A_src),						// Output
		.alu_B_src(alu_B_src), 
		.reg_write(reg_write), 
		.write_to_memory(write_to_memory),
		.pc_src(pc_src), 
		.reg_write_src(reg_write_src),
		.alu_cont(alu_cont)
	);
	
	datapath #(WIDTH, REG_BITS, ALU_CONT_BITS, IMM_BITS, OP_BITS)
	dp(
		.clk(clk),
		.reset(reset),
		.reg_write(reg_write),
		.alu_A_src(alu_A_src), 
		.alu_B_src(alu_B_src),
		.pc_en(pc_en),
		.pc_src(pc_src), 
		.reg_write_src(reg_write_src),
		.alu_cont(alu_cont),
		.data_from_mem_PC(data_from_mem_PC), 
		.data_from_mem_load(data_from_mem_load),
		.zero(),
		.op_code(op_code), 
		.ext_op_code(ext_op_code),
		.A_index(A_index),
		.B_index(B_index),
		.mem_address_PC(mem_address_PC), 
		.mem_address_load_stor(mem_address_load_stor),	
		.psr_flags(psr_flags), 
		.data_to_mem_stor(data_to_mem_stor)
	);
	
endmodule
