module instruction_reg #(parameter WIDTH = 16, IMM_BITS = 8, OP_BITS = 4, REG_BITS = 5)(
	input 	[WIDTH - 1 : 0]		input_instruction,
	output	[OP_BITS - 1 : 0]		op_code,
	output	[IMM_BITS - 1 : 0]		immediate_value,
	output 	[REG_BITS - 1 : 0] 		reg_A_index, reg_B_index
	); 

endmodule
