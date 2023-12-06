// Good
module vga_control (
	input clk, 
	input reset,
	
	output blank_n, 
	output reg h_sync,
	output reg v_sync, 
	output reg clk_25MHz,
	output reg [15:0] h_count, 
	output reg [15:0] v_count,
	output reg  h_bright,
	output reg  v_bright
	);
	
	// in terms of clock cycles
	localparam h_ts = 800;
	localparam h_tdisp = 640;
	localparam h_tpw = 96;
	localparam h_tfp = 16;
	localparam h_tbp = 40;
	
	// in terms of horizontal lines, not clock cycles
	localparam v_ts = 521;
	localparam v_tdisp = 480;
	localparam v_tpw = 2;
	localparam v_tfp = 10;
	localparam v_tbp = 29;
	
	 assign blank_n = v_bright && h_bright;
	
	//Using the push buttons we need to invert the clear logic
	always @(posedge clk) begin
	
		//when we push the clear button reset the lighting
		if(~reset) begin 
			h_count <= 0;
			v_count <= 0;
			clk_25MHz <= 0;
		end
		
		// only do stuff every other cycle to get 25MHz clock
		else if(clk_25MHz) begin
			clk_25MHz <= 0;
			//if we hit the limit of h_count reset the counter 
			if (h_count == h_tdisp + h_tfp + h_tpw + h_tbp) begin
				h_count <= 0;
				// if the vertical count hits its limit reset it to 0 otherwise increment
				if (v_count == v_tdisp + v_tfp + v_tpw + v_tbp) v_count <= 0;
				else v_count <= v_count + 1'b1;
			end
			else h_count <= h_count + 1'b1;
			
			// hcount checks
			//determines when to set line high or low so it can only be turned on during certain parts of the screen
			//sets h_sync to set high or low so it can only be turned on for certain parts of the screen.
			if(h_count == 0) begin
				h_bright <= 1;
				h_sync <= 1;
			end
			else if (h_count == h_tdisp + h_tfp) begin
				h_sync <= 0;
				h_bright <= 0;
			end
			// set high because it is not active
			else if (h_count == h_tdisp + h_tfp + h_tpw) h_sync <= 1; 
			
			// v_count stuff
			// same as the always block above except for frame and v_sync. 
			if(v_count == 0) begin
				v_bright <= 1;
				v_sync <= 1;
			end
			else if (v_count == v_tdisp + v_tfp) begin
				v_sync <= 0;
				v_bright <= 0;
			end
			//set high because it is not active	
			else if (v_count == v_tdisp + v_tfp + v_tpw) v_sync <= 1; 		
		end
		
		// two cycles have passed so flip clock
		else clk_25MHz <= 1;
	end
endmodule 