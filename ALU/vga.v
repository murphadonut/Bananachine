module vga #(
	parameter WIDTH = 16,
	parameter H_RES = 640, 
	parameter V_RES = 480, 
	parameter COUNTER_BITS = 10	
	)(
	input clk_50MHz, 
	input clear,	
	input[15:0] data_from_mem_vga,
	input[2:0] vga_counter,
	
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
	
	bit_gen #(WIDTH) bit_gen(
		.clk_50m(clk_50MHz),
		.btn_rst_n(clear),
		.data_from_mem_vga(data_from_mem_vga),
		.vga_counter(vga_counter),
		.bright(bright),
		.vga_hsync(h_sync),
		.vga_vsync(v_sync),
		.vga_r(red_out),
		.vga_g(green_out),
		.vga_b(blue_out),
		.clk_25MHz(clk_25MHz)
	);
	
	
endmodule 