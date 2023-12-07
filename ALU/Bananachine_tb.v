`timescale 1 ns / 1 ns
module bananachine_tb();
	reg clk, reset, left, right, start;
	wire vga_clk, vga_h_sync, vga_v_sync, vga_sync, vga_blank;
	wire [7:0] vga_red, vga_green, vga_blue;
	bananachine bm(
	//inputs
	.clk(clk),
	.reset(reset),
	.left(left), 
	.right(right), 
	.start(start),
	//outputs
	.vga_clk(vga_clk),
	.vga_h_sync(vga_h_sync),
	.vga_v_sync(vga_v_sync),
	.vga_sync(vga_sync),
	.vga_blank(vga_blank),
	.vga_red(vga_red),
	.vga_green(vga_green),
	.vga_blue(vga_blue)
	);
	
	initial
		begin
			reset = 0;
			#20;
			reset = 1;
			start = 0;
			left = 1;
			right = 1;
			#20;
		end
	
	
	always
		begin
			clk <= 1; #10;
			clk <= 0; #10;
		end
endmodule 