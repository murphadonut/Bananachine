module vga #(
	parameter H_RES = 640, 
	parameter V_RES = 480, 
	parameter COUNTER_BITS = 10, 
	parameter MX = 6000, 
	parameter MY = 6004, 
	parameter P1X = 6008, 
	parameter P1Y = 6012, 
	parameter P2X = 6016, 
	parameter P2Y = 6020
	
	)(
	
	input clk_50MHz, 
	input clear,	
	input[15:0] mx, 
	input[15:0] my, 
	input[15:0] p1x, 
	input[15:0] p1y, 
	input[15:0] p2x, 
	input[15:0] p2y,
	
	output clk_25MHz, 
	output h_sync, 
	output v_sync, 
	output sync_n, 
	output blank_n,
	output [7:0] red_out, 
	output [7:0] green_out, 
	output [7:0] blue_out
	);
	
	wire bright;
	
	assign sync_n = 0;
	assign blank_n = bright;
	
	bit_gen bit_gen(
		.clk_50m(clk_50MHz),
		.btn_rst_n(clear),
		.mx(mx),
		.my(my),
		.p1x(p1x),
		.p1y(p1y),
		.p2x(p2x),
		.p2y(p2y),
		.bright(bright),
		.vga_hsync(h_sync),
		.vga_vsync(v_sync),
		.vga_r(red_out),
		.vga_g(green_out),
		.vga_b(blue_out),
		.clk_25MHz(clk_25MHz)
	);
	
	
endmodule 