 `timescale 1 ns / 1 ns
module vga_tb();
	reg clk, clear;
	reg [15:0] data_from_mem_vga;
	reg [2:0] vga_counter;
	wire haclk, hsync, vsync, syncn, blankn;
	wire [7:0] redout, greenout, blueout;
	vga dut(
		.clk_50MHz(clk), 
		.clear(clear),
		.clk_25MHz(haclk), 
		.data_from_mem_vga(data_from_mem_vga),
		.vga_counter(vga_counter),
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
		#2000 //give it some time to set up memory
		
			clear = 0;
			#20;
			clear = 1;
			#20;
			vga_counter <= 3'b000;
			data_from_mem_vga <= 16'b0000000000001111;
			#20;
			vga_counter <= 3'b001;
			data_from_mem_vga <= 16'b0000000000001111;
			#20;
			vga_counter <= 3'b010;
			data_from_mem_vga <= 16'b0000000000100101;
			#20;
			vga_counter <= 3'b011;
			data_from_mem_vga <= 16'b0000000000100101;
			#20;
			vga_counter <= 3'b100;
			data_from_mem_vga <= 16'b0000000010000000;
			#20;
			vga_counter <= 3'b101;
			data_from_mem_vga <= 16'b0000000000000001;
			#20;
		end
	
	
	always
		begin
			clk <= 1; #10;
			clk <= 0; #10;
		end
endmodule 