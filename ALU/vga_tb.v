`timescale 1 ns / 1 ns
module vga_tb();
	reg clk, clear;
	wire haclk, hsync, vsync, syncn, blankn;
	wire [7:0] redout, greenout, blueout;
	vga dut(
		.clk_50MHz(clk), 
		.clear(clear),
		.clk_25MHz(haclk), 
		.h_sync(hsync), 
		.v_sync(vsync),
		.sync_n(syncn),
		.blank_n(blankn),
		.red_out(redout),
		.green_out(greenout), 
		.blue_out(blueout)
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