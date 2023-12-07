// Good
module sprite #(
	parameter CORDW = 16,      // signed coordinate width (bits)
	parameter SX_OFFS = 2,     // horizontal screen offset (pixels)
	parameter SPR_FILE = "",   // sprite bitmap file ($readmemh format)
	parameter SPR_WIDTH = 8,   // sprite bitmap width in pixels
	parameter SPR_HEIGHT = 8,  // sprite bitmap height in pixels
	parameter SPR_SCALE = 0,	// scale factor: 0=1x, 1=2x, 2=4x, 3=8x etc.
	parameter SPR_DATAW = 4		// data width: bits per pixel
	
   ) (
	
	input clk,										// clock
	input reset,									// reset
	input h_bright,								// start of active screen line
	input signed [CORDW-1:0] sx, 				// screen position
	input signed [CORDW-1:0] sy,				// screen position
	input signed [CORDW-1:0] sprx, 			// sprite position
	input signed [CORDW-1:0] spry,			// sprite position
	
	output reg  [SPR_DATAW-1:0] pix,			// pixel colour index
	output reg  drawing							// drawing at position (sx,sy)
	);
	
	// horizontal screen resolution (pixels)
	localparam H_RES = 640;
	
	// sprite bitmap ROM
	localparam SPR_ROM_DEPTH = SPR_WIDTH * SPR_HEIGHT;
	
	// pixel position
	reg [$clog2(SPR_ROM_DEPTH)-1:0] spr_rom_addr;
	
	// pixel colour
	wire [SPR_DATAW-1:0] spr_rom_data;

	// horizontal coordinate within sprite bitmap
	reg [$clog2(SPR_WIDTH)-1:0] bmap_x;

	// horizontal scale counter
	reg [SPR_SCALE:0] cnt_x;

	// for registering sprite position
	reg signed [CORDW-1:0] sprx_r;
	reg signed [CORDW-1:0] spry_r;

	// status flags: used to change state
	reg signed [CORDW-1:0]  spr_diff;  // diff vertical screen and sprite positions
	
	// sprite active on this line
	reg spr_active;
	
	// begin sprite drawing
	reg spr_begin;
	
	// end of sprite on this line
	reg spr_end;
	
	// end of screen line, corrected for sx offset
	reg line_end;
	
	// stupid stupid
	wire [31:0] stupid;
	assign stupid = spr_diff * SPR_WIDTH + (sx - sprx_r) + SX_OFFS;
	
		
	rom_async #(
		.WIDTH(SPR_DATAW),
		.DEPTH(SPR_ROM_DEPTH),
		.INIT_F(SPR_FILE)
	) spr_rom (
		.addr(spr_rom_addr),
		.data(spr_rom_data)
	);
	
	// guess this has to blocking in order to display sprites correctly.
	always @(*) begin
		spr_diff = (sy - spry_r) >>> SPR_SCALE;  // arithmetic right-shift
		spr_active = (spr_diff >= 0) && (spr_diff < SPR_HEIGHT);
		spr_begin = (sx >= sprx_r - SX_OFFS);
		spr_end = (bmap_x == SPR_WIDTH-1);
		line_end = (sx == H_RES - SX_OFFS);
	end

	// sprite state machine
	// Conditions
	localparam IDLE 		= 3'b000;
	localparam REG_POS	= 3'b001;
	localparam ACTIVE		= 3'b010;
	localparam WAIT_POS	= 3'b011;
	localparam SPR_LINE	= 3'b100;
	localparam WAIT_DATA	= 3'b101;
   reg [2:0] state;

	always @(posedge clk) begin
		if (~h_bright) begin  // prepare for new line
			state <= REG_POS;
			pix <= 0;
			drawing <= 0;
		end
		else begin
			case (state)
				REG_POS: begin
					state <= ACTIVE;
					sprx_r <= sprx;
					spry_r <= spry;
				end
				ACTIVE: state <= spr_active ? WAIT_POS : IDLE;
				WAIT_POS: begin
					if (spr_begin) begin
						state <= SPR_LINE;
						spr_rom_addr <= stupid[7:0];
						bmap_x <= 0;
						cnt_x <= 0;
					end
				end
				SPR_LINE: begin
					if (line_end) state <= WAIT_DATA;
						pix <= spr_rom_data;
						drawing <= 1;
						if (SPR_SCALE == 0 || cnt_x == 2**SPR_SCALE-1) begin
							if (spr_end) state <= WAIT_DATA;
							spr_rom_addr <= spr_rom_addr + 1'b1;
							bmap_x <= bmap_x + 1'b1;
							cnt_x <= 0;
						end 
						else cnt_x <= cnt_x + 1'b1;
					end
					WAIT_DATA: begin
						state <= IDLE;  // 1 cycle between address set and data receipt
						pix <= 0;  // default colour
						drawing <= 0;
					end
					default: state <= IDLE;
				endcase
			end

			if (~reset) begin
				state <= IDLE;
            spr_rom_addr <= 0;
            bmap_x <= 0;
            cnt_x <= 0;
            pix <= 0;
            drawing <= 0;
        end
    end
endmodule
