module instruction_reg #(parameter WIDTH = 16, IMM_BITS = 8, OP_BITS = 4, REG_BITS = 5)(
	input 	[WIDTH - 1 : 0]			input_instruction,
	output	[OP_BITS - 1 : 0]			op_code,
	output	[OP_BITS - 1 : 0]			ext_op_code,
	output	[IMM_BITS - 1 : 0]		immediate_value,
	output 	[REG_BITS - 1 : 0] 		A_index_out, B_index_out
	); 

endmodule
