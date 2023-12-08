// Good
module vga (
	input clk, 
	input reset,	
	input[15:0] mx, 
	input[15:0] my, 
	input[15:0] p1x, 
	input[15:0] p1y, 
	input[15:0] p2x, 
	input[15:0] p2y,
	input[15:0] cont,
	
	output clk_25MHz, 
	output h_sync, 
	output v_sync, 
	output sync_n, 
	output blank_n,
	output [7:0] red_out, 
	output [7:0] green_out, 
	output [7:0] blue_out
	);
	
	assign sync_n = 0;
	
	bit_gen bit_gen(
		.clk(clk),
		.reset(reset),
		.mx(mx),
		.my(my),
		.p1x(p1x),
		.p1y(p1y),
		.p2x(p2x),
		.p2y(p2y),
		.cont(cont),
		.blank_n(blank_n),
		.vga_hsync(h_sync),
		.vga_vsync(v_sync),
		.vga_r(red_out),
		.vga_g(green_out),
		.vga_b(blue_out),
		.clk_25MHz(clk_25MHz)
	);
	
	
endmodule 