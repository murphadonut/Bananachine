module bit_gen (
    input  wire clk_50m,      // 50 MHz clock
    input  wire btn_rst_n,		// reset button
	 output      bright, 
    output reg  vga_hsync,    // horizontal sync
    output reg  vga_vsync,    // vertical sync
    output reg  [7:0] vga_r,  // 4-bit VGA red
    output reg  [7:0] vga_g,  // 4-bit VGA green
    output reg  [7:0] vga_b,  // 4-bit VGA blue
	output wire  clk_25MHz		// VGA clk
    );

  // display sync signals and coordinates
    localparam CORDW = 16;  // signed coordinate width (bits)
    wire signed [CORDW-1:0] sx, sy;
    wire hsync, vsync;
    wire frame, line;
	 
	 vga_control control(
		.clk_50MHz(clk_50m),
		.clear(btn_rst_n),
		.bright(bright), 
		.h_sync(hsync), 
		.v_sync(vsync), 
		.clk_25MHz(clk_25MHz),
		.h_count(sx), 
		.v_count(sy),
		.frame(frame),    // high at start of frame
		.line(line) 		 // high at start of line
	);

    // screen dimensions (must match display_inst)
    localparam H_RES = 640;
    localparam V_RES = 480;

	 
	 // colour parameters
    localparam CHANW = 4;         // colour channel width (bits)
    localparam COLRW = 3*CHANW;   // colour width: three channels (bits)
    localparam CIDXW = 4;         // colour index width (bits)
    localparam TRANS_INDX = 'hF;  // transparant colour index
    localparam BG_COLR = 'h137;   // background colour
			
    // sprite parameters
    localparam SPR_WIDTH  = 16;  // bitmap width in pixels
    localparam SPR_HEIGHT = 10;  // bitmap height in pixels
    localparam SPR_WIDTH2  = 8;  // bitmap width in pixels
    localparam SPR_HEIGHT2 = 8;  // bitmap height in pixels
    localparam SPR_SCALE  = 3;  // 2^3 = 8x scale
    localparam SPR_DATAW  = 4;  // bits per pixel
    localparam SPR_DRAWW  = SPR_WIDTH  * 2**SPR_SCALE;  // draw width
    localparam SPR_DRAWH  = SPR_HEIGHT * 2**SPR_SCALE;  // draw height
    localparam SPR_SPX    = 4;  // horizontal speed (pixels/frame)
    localparam SPR_FILE   = "real_banana.mem";  // bitmap file
	 localparam SPR_FILE2	= "real_banana.mem";

    // draw sprite at position (sprx,spry)
    reg signed [CORDW-1:0] sprx, spry;
    reg dx;  // direction: 0 is right/down

    // update sprite position once per frame
    always @(posedge clk_25MHz) begin
        if (frame) begin
            if (dx == 0) begin  // moving right
                if (sprx + SPR_DRAWW >= H_RES + 2*SPR_DRAWW) dx <= 1;  // move left
                else sprx <= sprx + SPR_SPX;  // continue right
            end else begin  // moving left
                if (sprx <= -2*SPR_DRAWW) dx <= 0;  // move right
                else sprx <= sprx - SPR_SPX;  // continue left
            end
        end
        if (btn_rst_n) begin  // centre sprite and set direction right
            sprx <= H_RES/2 - SPR_DRAWW/2;
            spry <= V_RES/2 - SPR_DRAWH/2;
            dx <= 0;
        end
    end

    wire drawing;  // drawing at (sx,sy)
    wire [SPR_DATAW-1:0] pix;  // pixel colour index
    sprite #(
        .CORDW(CORDW),
        .H_RES(H_RES),
        .SPR_FILE(SPR_FILE),
        .SPR_WIDTH(SPR_WIDTH),
        .SPR_HEIGHT(SPR_HEIGHT),
        .SPR_SCALE(SPR_SCALE),
        .SPR_DATAW(SPR_DATAW)
        ) sprite_f (
        .clk(clk_25MHz),
        .rst(btn_rst_n),
        .line(line),
        .sx(sx),
        .sy(sy),
        .sprx(sprx),
        .spry(spry),
        .pix(pix),
        .drawing(drawing)
    );
	 
	 wire drawing2;  // drawing at (sx,sy)
    wire [SPR_DATAW-1:0] pix2;  // pixel colour index
    sprite #(
        .CORDW(CORDW),
        .H_RES(H_RES),
        .SPR_FILE(SPR_FILE2),
        .SPR_WIDTH(SPR_WIDTH),
        .SPR_HEIGHT(SPR_HEIGHT),
        .SPR_SCALE(SPR_SCALE),
        .SPR_DATAW(SPR_DATAW)
        ) sprite_f2 (
        .clk(clk_25MHz),
        .rst(btn_rst_n),
        .line(line),
        .sx(sx),
        .sy(sy),
        .sprx(100),
        .spry(25),
        .pix(pix2),
        .drawing(drawing2)
    );
	 
	 wire drawing3;  // drawing at (sx,sy)
    wire [SPR_DATAW-1:0] pix3;  // pixel colour index
	 sprite #(
		  .CORDW(CORDW),
        .H_RES(H_RES),
        .SPR_FILE("monkeBIG.mem"),
        .SPR_WIDTH(32),
        .SPR_HEIGHT(20),
        .SPR_SCALE(2),
        .SPR_DATAW(SPR_DATAW)
        ) sprite_f3 (
        .clk(clk_25MHz),
        .rst(btn_rst_n),
        .line(line),
        .sx(sx),
        .sy(sy),
        .sprx(200),
        .spry(125),
        .pix(pix3),
        .drawing(drawing3)
    );
	
	reg [SPR_DATAW-1:0] pixel;
	
	always@(*)begin
		if(drawing && (pix != TRANS_INDX))begin
		pixel = pix;
		end else if(drawing2 && (pix2 != TRANS_INDX)) begin
		pixel = pix2;
		end else begin
		pixel = pix3;
		end
	end
	 
	// colour lookup table
	wire [COLRW-1:0] spr_pix_colr;
   clut_mem clut_mem (  
        .we(1'b0),
        .clk_read(clk_25MHz),
        .clk_write(clk_25MHz),
        .data_in(12'b000000000000),
		  .addr_read(pixel),
		  .addr_write(1'b0),
        .data_out(spr_pix_colr)
    );

	 reg drawing_t1;
	 always @(posedge clk_25MHz) begin
		drawing_t1 <= (drawing && (pix != TRANS_INDX)) || (drawing2 && (pix2 != TRANS_INDX)) || (drawing3 && (pix3 != TRANS_INDX));
	 end
	 
    // paint colour: yellow sprite, blue background
    reg [7:0] paint_r, paint_g, paint_b;
    always @(*) begin
        paint_r = (drawing_t1) ? {spr_pix_colr[COLRW - 1 : COLRW - CHANW], 4'b0000} : {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
        paint_g = (drawing_t1) ? {spr_pix_colr[COLRW - 1 - CHANW : COLRW - 2*CHANW], 4'b0000} : {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
        paint_b = (drawing_t1) ? {spr_pix_colr[COLRW - 1 - 2*CHANW : COLRW - 3*CHANW], 4'b0000} : {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
    end

    // display colour: paint colour but black in blanking interval
    reg [7:0] display_r, display_g, display_b;
    always @(*) begin
        display_r = (bright) ? paint_r : 8'b00000000;
        display_g = (bright) ? paint_g : 8'b00000000;
        display_b = (bright) ? paint_b : 8'b00000000;
    end

    // VGA Pmod output
    always @(posedge clk_25MHz) begin
        vga_hsync <= hsync;
        vga_vsync <= vsync;
        vga_r <= display_r;
        vga_g <= display_g;
        vga_b <= display_b;
    end
endmodule
