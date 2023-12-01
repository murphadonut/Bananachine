module vga #(parameter H_RES = 640, V_RES = 480, COUNTER_BITS = 10, MX = 6000, MY = 6004, P1X = 6008, P1Y = 6012, P2X = 6016, P2Y = 6020)(
		input clk_50MHz, clear,
		output[15:0] mx, my, p1x, p1y, p2x p2y,
		output clk_25MHz, h_sync, v_sync, sync_n, blank_n,
		output [7 : 0] red_out, green_out, blue_out
	);
	
	wire bright;
	
	assign sync_n = 0;
	assign blank_n = bright;
	
	bit_gen bit_gen(
		.clk_50m(clk_50MHz),     // 50 MHz clock
		.btn_rst_n(clear),		// reset button
		.bright(bright),
		.vga_hsync(h_sync),    // horizontal sync
		.vga_vsync(v_sync),    // vertical sync
		.vga_r(red_out),  // 4-bit VGA red
		.vga_g(green_out),  // 4-bit VGA green
		.vga_b(blue_out),
		.clk_25MHz(clk_25MHz)
	);
	
	
endmodule 