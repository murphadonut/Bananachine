module bit_gen (
   input clk_50m,      // 50 MHz clock
   input btn_rst_n,		// reset button
	input [15:0] data_from_mem_vga,
	input[2:0] vga_counter, 
	
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
	 reg signed [CORDW-1:0] mx, my, p1x, p1y, p2x, p2y;
    wire hsync, vsync;
    wire frame, line;
	 
<<<<<<< Updated upstream
	 vga_control control(
		.clk_50MHz(clk_50m),
		.clear(btn_rst_n),
		.bright(bright), 
=======
	// colour parameters
	localparam CHANW = 4;         // colour channel width (bits)
	localparam COLRW = 3*CHANW;   // colour width: three channels (bits)
	localparam CIDXW = 4;         // colour index width (bits)
	localparam TRANS_INDX = 'hF;	// transparant colour index
	localparam BG_COLR = 'h137;	// background colour
			
	// sprite parameters
	localparam SPR_WIDTH  = 16;	// bitmap width in pixels
	localparam SPR_HEIGHT = 16;	// bitmap height in pixels
	localparam SPR_WIDTH2  = 8;	// bitmap width in pixels
	localparam SPR_HEIGHT2 = 8;	// bitmap height in pixels
	localparam SPR_SCALE  = 2;		// 2^3 = 8x scale
	localparam SPR_DATAW  = 4;		// bits per pixel
	localparam SPR_SPX    = 4;		// horizontal speed (pixels/frame)
	
	// files
	localparam SPR_FILE   = "real_banana.mem";
	localparam SPR_FILE2	= "letter_f.mem";
	localparam SPR_FILE3	= "letter_m.mem";

	// timings
	vga_control control(
		.clk(clk),
		.reset(reset),
		.blank_n(blank_n), 
>>>>>>> Stashed changes
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
    localparam SPR_HEIGHT = 16;  // bitmap height in pixels
    localparam SPR_WIDTH2  = 8;  // bitmap width in pixels
    localparam SPR_HEIGHT2 = 8;  // bitmap height in pixels
    localparam SPR_SCALE  = 3;  // 2^3 = 8x scale
    localparam SPR_DATAW  = 4;  // bits per pixel
    localparam SPR_SPX    = 4;  // horizontal speed (pixels/frame)
    localparam SPR_FILE   = "real_banana.mem";  // bitmap file
	 localparam SPR_FILE2	= "letter_f.mem";
	 
	 
	 always @(negedge clk_50m)begin
		case(vga_counter)
			3'b000: mx  <= data_from_mem_vga;
			3'b001: my  <= data_from_mem_vga;
			3'b010: p1x <= data_from_mem_vga;
			3'b011: p1y <= data_from_mem_vga;
			3'b100: p2x <= data_from_mem_vga;
			3'b101: p2y <= data_from_mem_vga;
			default:;
		endcase
	 end
	 
	 always @(posedge clk_25MHz) begin
		if (frame) begin
			
		end
	 end

    wire drawing;  // monkey
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
        .sprx(mx),
        .spry(my),
        .pix(pix),
        .drawing(drawing)
    );
	 
	 wire drawing2;  // platform 1
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
        .sprx(p1x),
        .spry(p1y),
        .pix(pix2),
        .drawing(drawing2)
    );
	 
	 wire drawing3;  // platform 2
    wire [SPR_DATAW-1:0] pix3;  // pixel colour index
	 sprite #(
		  .CORDW(CORDW),
        .H_RES(H_RES),
        .SPR_FILE("letter_m.mem"),
        .SPR_WIDTH(SPR_WIDTH),
        .SPR_HEIGHT(SPR_HEIGHT),
        .SPR_SCALE(SPR_SCALE),
        .SPR_DATAW(SPR_DATAW)
        ) sprite_f3 (
        .clk(clk_25MHz),
        .rst(btn_rst_n),
        .line(line),
        .sx(sx),
        .sy(sy),
        .sprx(p2x),
        .spry(p2y),
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
