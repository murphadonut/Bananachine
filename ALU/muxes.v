module mux2 #(parameter WIDTH = 16)(
	input 	selection,
	input 	[WIDTH - 1 : 0] input_1, input_2,
	output 	[WIDTH - 1 : 0] mux2_output);
	assign mux2_output = selection ? input_2 : input_1;
endmodule 


module mux4 #(parameter WIDTH = 8)(
   input      [1:0] selection,
	input      [WIDTH-1:0] input_1, input_2, input_3, input_4,
   output reg [WIDTH-1:0] mux4_output);
   always @(*)
      case(selection)
         2'b00: mux4_output <= input_1;
         2'b01: mux4_output <= input_2;
         2'b10: mux4_output <= input_3;
         2'b11: mux4_output <= input_4;
      endcase
endmodule


module flopenr #(parameter WIDTH = 8)(
	input 		clk, reset, en,
   input			[WIDTH - 1 : 0] d, 
   output reg 	[WIDTH - 1 : 0] q);
   always @(posedge clk)
      if (~reset) q <= 0;
      else if(en) q <= d;
endmodule



module flopr #(parameter WIDTH = 8)(
	input			clk, reset,
   input      	[WIDTH-1:0] d, 
   output reg 	[WIDTH-1:0] q);
   always @(posedge clk)
      if   (~reset) q <= 0;
      else q <= d;
endmodule 