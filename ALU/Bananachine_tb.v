module Bananachine_tb();
	reg clk, reset;
	Bananachine bm(clk, reset);
	
	initial begin
		reset <= 0;
		#22
		reset <= 1;
	end
	
	
	always
	begin
		clk <= 1;
		#10
		clk <= 0;
		#10
		clk <= 1;
		#10
		clk <= 0;
		#10
		clk <= 1;
		#10
		clk <= 0;
	end
	
endmodule 