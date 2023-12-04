module mux2 #(
	parameter WIDTH = 16) (
	input selection,
	input [WIDTH - 1 : 0] input_1, 
	input [WIDTH - 1 : 0] input_2,
	
	output 	[WIDTH - 1 : 0] mux2_output);
	
	assign mux2_output = selection ? input_2 : input_1;
endmodule 


module mux4 #(
	parameter WIDTH = 16) (
	
   input      [1:0] selection,
	input [WIDTH-1:0] input_1, 
	input [WIDTH-1:0] input_2, 
	input [WIDTH-1:0] input_3, 
	input [WIDTH-1:0] input_4,
   output reg [WIDTH-1:0] mux4_output);
   always @(*)
      case(selection)
         2'b00: mux4_output <= input_1;
         2'b01: mux4_output <= input_2;
         2'b10: mux4_output <= input_3;
         2'b11: mux4_output <= input_4;
      endcase
endmodule

module mux8 #(
	parameter WIDTH = 16) (
	
   input      [2:0] selection,
	input [WIDTH-1:0] input_1, 
	input [WIDTH-1:0] input_2, 
	input [WIDTH-1:0] input_3, 
	input [WIDTH-1:0] input_4,
	input [WIDTH-1:0] input_5,
	input [WIDTH-1:0] input_6,
	input [WIDTH-1:0] input_7,
	input [WIDTH-1:0] input_8,
   output reg [WIDTH-1:0] mux8_output);
   always @(*)
      case(selection)
         3'b000: mux8_output <= input_1;
         3'b001: mux8_output <= input_2;
         3'b010: mux8_output <= input_3;
         3'b011: mux8_output <= input_4;
			3'b100: mux8_output <= input_5;
			3'b101: mux8_output <= input_6;
			3'b110: mux8_output <= input_7;
			3'b111: mux8_output <= input_8;
      endcase
endmodule


module flopenr #(parameter WIDTH = 16)(
	input 		clk, reset, en,
   input			[WIDTH - 1 : 0] d, 
   output reg 	[WIDTH - 1 : 0] q);
   always @(posedge clk)
      if (~reset) q <= 0;
      else if(en) q <= d;
endmodule



module flopr #(parameter WIDTH = 16)(
	input			clk, reset,
   input      	[WIDTH-1:0] d, 
   output reg 	[WIDTH-1:0] q);
   always @(posedge clk)
      if   (~reset) q <= 0;
      else q <= d;
endmodule 