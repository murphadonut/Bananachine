module instruction_reg #(parameter WIDTH = 16, IMM_BITS = 8, OP_BITS = 4, REG_BITS = 5)(
	input 	[WIDTH - 1 : 0]			input_instruction,
	output 	is_immediate, is_alu_non_immediate, is_bcond,
	output	[OP_BITS - 1 : 0]			op_code,
	output	[OP_BITS - 1 : 0]			ext_op_code,
	output	[IMM_BITS - 1 : 0]		immediate_value,
	output 	[REG_BITS - 1 : 0] 		A_index_out, B_index_out
	); 
	
	assign op_code = input_instruction[15:12];
	assign A_index_out = input_instruction[11:8];
	assign ext_op_code = input_instruction[7:4];
	assign immediate_value = input_instruction[7:0];
	assign B_index_out = input_instruction[3:0];
	
	assign is_immediate = op_code[OP_BITS - 3 : 0] != 2'b00;
	assign is_alu_non_immediate = op_code == 4'b0000;
	assign is_bcond = op_code == 4'b1100;

endmodule
