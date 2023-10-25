module mux2 #(parameter WIDTH = 16)(
	input [WIDTH - 1 : 0] mux2_input_1, mux2_input_2,
	input selection,
	output [WIDTH - 1 : 0] mux2_output
	);
	
	assign mux2_output = selection ? mux2_input_2 : mux2_input_1;
endmodule 