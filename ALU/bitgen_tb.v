`timescale 1 ns / 1 ns
module bitgen_tb();
	reg clk, clear;
	wire haclk, hsync, vsync, syncn, bright;
	wire [7:0] redout, greenout, blueout;

	BitGen dut(
		.clk_50m(clk), 
		.btn_rst_n(clear),
		.bright(bright),
		.clk_25MHz(haclk), 
		.vga_hsync(hsync), 
		.vga_vsync(vsync),
		.vga_r(redout),
		.vga_g(greenout), 
		.vga_b(blueout)
		);
	
	initial
		begin
			clear = 0;
			#20;
			clear = 1;
			#20;
		end
	
	
	always
		begin
			clk <= 1; #10;
			clk <= 0; #10;
		end
endmodule 