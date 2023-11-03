`timescale 1 ns / 1 ns
module Bananachine_tb();
	reg clk, reset;
	Bananachine bm(clk, reset);
	
	initial
		begin
			reset = 0;
			#20;
			reset = 1;
			#20;
		end
	
	
	always
		begin
			clk <= 1; #10;
			clk <= 0; #10;
		end
endmodule 