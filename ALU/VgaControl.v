module vga_control #(parameter H_RES = 640, V_RES = 480, COUNTER_BITS = 10)(
		input clk_50MHz, clear,
		output bright, 
		output reg h_sync, v_sync, clk_25MHz,
		output reg [COUNTER_BITS - 1 : 0] h_count, v_count
	);
	
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
	
	reg h_bright, v_bright;
	assign bright = h_bright && v_bright;
	
	//Using the push buttons we need to invert the clear logic
	always @(negedge clear, posedge clk_50MHz)
	begin
		if(~clear) //when we push the clear button reset the lighting
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
	
		//determines when to set hbright high or low so it can only be turned on during certain parts of the screen
		//sets h_sync to set high or low so it can only be turned on for certain parts of the screen.
	always @(h_count)
		begin
			if(h_count == 0) 
				begin
					h_bright = 1;
					h_sync = 1;
				end
			else if (h_count == h_tdisp) h_bright = 0; 
			else if (h_count == h_tdisp + h_tfp) h_sync = 0;
			else if (h_count == h_tdisp + h_tfp + h_tpw) h_sync = 1;
		end
		
		//same as the always block above except for V_bright and v_sync. 
	always @(v_count)
		begin
			if(v_count == 0) 
				begin
					v_bright = 1;
					v_sync = 1;
				end
			else if (v_count == v_tdisp) v_bright = 0;
			else if (v_count == v_tdisp + v_tfp) v_sync = 0;
			else if (v_count == v_tdisp + v_tfp + v_tpw) v_sync = 1; //set high because it is not active
		end
endmodule 