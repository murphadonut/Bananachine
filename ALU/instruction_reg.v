module instruction_reg #(
	parameter WIDTH = 16, 
	parameter REG_BITS = 4, 
	parameter OP_CODE_BITS = 4, 
	parameter EXT_OP_CODE_BITS = 4) (
	
	input clk, 
	input reset, 
	input instruction_en,
	input [WIDTH - 1 : 0] input_instruction,
	
	output [OP_CODE_BITS - 1 : 0]	op_code, 
	output [EXT_OP_CODE_BITS - 1 : 0] ext_op_code,
	output [WIDTH - 1 : 0] immediate_value,
	output [REG_BITS - 1 : 0] A_index_out, 
	output [REG_BITS - 1 : 0] B_index_out
	); 
	
	flopenr #(OP_CODE_BITS)
	op_code_flopr(
		.clk(clk),
		.reset(reset),
		.en(instruction_en),
		.d(input_instruction[15:12]),
		.q(op_code)
	);
	
	flopenr #(EXT_OP_CODE_BITS)
	ext_op_code_flopr(
		.clk(clk),
		.reset(reset),
		.en(instruction_en),
		.d(input_instruction[7:4]),
		.q(ext_op_code)
	);
	
	flopenr #(WIDTH)
	immediate_value_flopr(
		.clk(clk),
		.reset(reset),
		.en(instruction_en),
		.d({8'b00000000, input_instruction[7:0]}),
		.q(immediate_value)
	);
	
	flopenr #(REG_BITS)
	A_index_flopr(
		.clk(clk),
		.reset(reset),
		.en(instruction_en),
		.d(input_instruction[11:8]),
		.q(A_index_out)
	);
	
	flopenr #(REG_BITS)
	B_index_flopr(
		.clk(clk),
		.reset(reset),
		.en(instruction_en),
		.d(input_instruction[3:0]),
		.q(B_index_out)
	);
	
endmodule
