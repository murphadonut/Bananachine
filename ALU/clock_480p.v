// Project F Library - 640x480p60 Clock Generation (iCE40)
// (C)2022 Will Green, open source hardware released under the MIT License
// Learn more at https://projectf.io

`default_nettype none
`timescale 1ns / 1ps

// Generates 25.125 MHz (640x480 59.8 Hz) with 12 MHz input clock
// iCE40 PLLs are documented in Lattice TN1251 and ICE Technology Library

module clock_480p (
    input  wire clk_50m,        // input clock (12 MHz)
    input  wire rst,            // reset
    output      clk_pix,        // pixel clock
    output reg  clk_pix_locked  // pixel clock locked?
    );

    reg locked;
	 reg h_count, v_count, clk_25MHz;
     // in terms of clock cycles
	localparam h_ts 	= 800;
	localparam h_tdisp = 640;
	localparam h_tpw 	= 96;
	localparam h_tfp 	= 16;
	localparam h_tbp 	= 48;
	
	// in terms of horizontal lines, not clock cycles
	localparam v_ts		= 521;
	localparam v_tdisp	= 480;
	localparam v_tpw	= 2;
	localparam v_tfp	= 10;
	localparam v_tbp	= 29;
	
	 always @(negedge rst, posedge clk_50m)
		begin
			if(~rst) //when we push the clear button reset the lighting
				begin
					h_count = 0;
					v_count = 0;
					clk_25MHz = 0;
				end
			else if(clk_25MHz)
				begin
					clk_25MHz = 0;
					if (h_count == h_tdisp + h_tfp + h_tpw + h_tbp) //if we hit the limit of h_count reset the counter
						begin 
							h_count = 0;
							if (v_count == v_tdisp + v_tfp + v_tpw + v_tbp) v_count = 0; // if the vertical count hits its limit reset it to 0 otherwise increment
							else v_count = v_count + 1;
						end
					else h_count = h_count + 1;
				end
			else clk_25MHz = 1;
		end

		assign clk_pix = clk_25MHz;
    // ensure clock lock is synced with pixel clock
    reg locked_sync_0;
    always @(posedge clk_pix) begin
        locked_sync_0 <= locked;
        clk_pix_locked <= locked_sync_0;
    end
endmodule 