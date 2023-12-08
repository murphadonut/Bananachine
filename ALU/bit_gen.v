// Good
module bit_gen (
   input clk,
   input reset,
	input[15:0] mx, 
	input[15:0] my, 
	input[15:0] p1x, 
	input[15:0] p1y, 
	input[15:0] p2x, 
	input[15:0] p2y,
	input[15:0] cont,
	
	output blank_n, 
	output clk_25MHz,
   output reg  vga_hsync,
   output reg  vga_vsync,
   output reg  [7:0] vga_r,
	output reg  [7:0] vga_g,
	output reg  [7:0] vga_b
	);

	// display sync signals and coordinates
	localparam CORDW = 16;  // signed coordinate width (bits)
	wire signed [CORDW-1:0] sx;
	wire signed [CORDW-1:0] sy;
	wire hsync;
	wire vsync;
	wire v_bright;
	wire h_bright;
	 
	// colour parameters
	localparam CHANW = 4;         // colour channel width (bits)
	localparam COLRW = 3*CHANW;   // colour width: three channels (bits)
	localparam CIDXW = 4;         // colour index width (bits)
	localparam TRANS_INDX = 'hF;	// transparant colour index
	localparam BG_COLR = 'h137;	// background colour
			
	// sprite parameters
	localparam SPR_WIDTH  = 16;	// bitmap width in pixels
	localparam SPR_HEIGHT = 10;	// bitmap height in pixels
	localparam SPR_WIDTH2  = 8;	// bitmap width in pixels
	localparam SPR_HEIGHT2 = 8;	// bitmap height in pixels
	localparam SPR_SCALE  = 2;		// 2^3 = 8x scale
	localparam SPR_DATAW  = 4;		// bits per pixel
	localparam SPR_SPX    = 4;		// horizontal speed (pixels/frame)
	
	// files
	localparam SPR_FILE   = "real_banana.mem";
	localparam SPR_FILE2	= "letter_f.mem";
	localparam SPR_FILE3	= "letter_m.mem";
	localparam SPR_FILE4 = "monke.mem";
	
	

	// timings
	vga_control control(
		.clk(clk),
		.reset(reset),
		.blank_n(blank_n), 
		.h_sync(hsync), 
		.v_sync(vsync), 
		.clk_25MHz(clk_25MHz),
		.h_count(sx), 
		.v_count(sy),
		.v_bright(v_bright),
		.h_bright(h_bright)
	);
	
	// monkey
	wire drawing_m;
	wire [SPR_DATAW-1:0] pix;
	sprite #(
		.CORDW(CORDW),
		.SPR_FILE(SPR_FILE4),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
		
		) sprite_m (
		.clk(clk_25MHz),
		.reset(reset),
		.h_bright(h_bright),
		.sx(sx),
		.sy(sy),
		.sprx(mx),
		.spry(my),
		.pix(pix),
		.drawing(drawing_m)
	);
	 
	// platform1
	wire drawing_p1;
	wire [SPR_DATAW-1:0] pix2;
	sprite #(
		.CORDW(CORDW),
		.SPR_FILE(SPR_FILE),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
		
		) sprite_p1 (
		.clk(clk_25MHz),
		.reset(reset),
		.h_bright(h_bright),
		.sx(sx),
		.sy(sy),
		.sprx(p1x),
		.spry(p1y),
		.pix(pix2),
		.drawing(drawing_p1)
	);
	
	// platform 2
	wire drawing_p2;
	wire [SPR_DATAW-1:0] pix3;
	sprite #(
		.CORDW(CORDW),
		.SPR_FILE(SPR_FILE),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
		
		) sprite_p2 (
		.clk(clk_25MHz),
		.reset(reset),
		.h_bright(h_bright),
		.sx(sx),
		.sy(sy),
		.sprx(p2x),
		.spry(p2y),
		.pix(pix3),
		.drawing(drawing_p2)
	);
	
	//reg [17:0] bin;
	wire [23:0] bcd;
	//assign bin = cont;
	
	bin2bcd bcdee(
		.bin(cont),
		.bcd(bcd)
	);
	
	
	reg [SPR_DATAW-1:0] pixel;
	
	always @(posedge clk) begin
		if(drawing_m && (pix != TRANS_INDX)) pixel <= pix;
		else if(drawing_p1 && (pix2 != TRANS_INDX)) pixel <= pix2;
		else pixel <= pix3;
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
		drawing_t1 <= (drawing_m && (pix != TRANS_INDX)) || (drawing_p1 && (pix2 != TRANS_INDX)) || (drawing_p2 && (pix3 != TRANS_INDX));
	 end
	 
 reg [7:0] paint_r, paint_g, paint_b;
    always @(*) begin
	 if(sx > 540 && sx < 560 && sy < 30 && sy > 0)begin// first number
		 case(bcd[15:12])
			4'b0000: begin //0
			 if(sx < 545) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555 ) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0001:begin//1
			 if(sx > 545 && sx < 555) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0010:begin//2
			 if(sx < 545 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0011: begin//3
			  if(sx > 555 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0100:begin//4
			 if(sx > 555 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 545 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0101: begin//5
			 if(sx < 545 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0110: begin//6 
			 if(sx < 545 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 545 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0111:begin//7
			 if(sx > 555) begin //right
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1000: begin//8
			 if(sx < 545) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1001:begin//9
			 if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 545 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 555) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			default: begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			end
		 endcase
		end
		else if(sx > 565 && sx < 585 && sy < 30 && sy > 0)begin// Second number
		 case(bcd[11:8])
			4'b0000: begin //0
			 if(sx < 570) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580 ) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0001:begin//1
			 if(sx > 570 && sx < 580) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0010:begin//2
			 if(sx < 570 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0011: begin//3
			  if(sx > 580 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0100:begin//4
			 if(sx > 580 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 570 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0101: begin//5
			 if(sx < 570 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0110: begin//6 
			 if(sx < 570 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 570 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0111:begin//7
			 if(sx > 580) begin //right
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1000: begin//8
			 if(sx < 570) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1001:begin//9
			 if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 570 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 580) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			default: begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			end
		 endcase
		end
		else if(sx > 590 && sx < 610 && sy < 30 && sy > 0)begin// first number
		 case(bcd[7:4])
			4'b0000: begin //0
			 if(sx < 595) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605 ) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0001:begin//1
			 if(sx > 595 && sx < 605) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0010:begin//2
			 if(sx < 595 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0011: begin//3
			  if(sx > 605 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0100:begin//4
			 if(sx > 605 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 595 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0101: begin//5
			 if(sx < 595 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0110: begin//6 
			 if(sx < 595 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 595 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0111:begin//7
			 if(sx > 605) begin //right
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1000: begin//8
			 if(sx < 595) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1001:begin//9
			 if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 595 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 605) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			default: begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			end
		 endcase
		end
		else if(sx > 615 && sx < 635 && sy < 30 && sy > 0)begin// first number
		 case(bcd[3:0])
			4'b0000: begin //0
			 if(sx < 620) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630 ) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0001:begin//1
			 if(sx > 620 && sx < 630) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0010:begin//2
			 if(sx < 620 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0011: begin//3
			  if(sx > 630 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0100:begin//4
			 if(sx > 630 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630 && sy < 15) begin//right top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 620 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0101: begin//5
			 if(sx < 620 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0110: begin//6 
			 if(sx < 620 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630 && sy > 15) begin //right bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			   else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 620 && sy > 15) begin //left bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b0111:begin//7
			 if(sx > 630) begin //right
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1000: begin//8
			 if(sx < 620) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			4'b1001:begin//9
			 if(sy < 5) begin //top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx < 620 && sy < 15) begin//left top
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			  else if(sy > 25) begin // bottom
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sy > 12 && sy < 17) begin // middle
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else if(sx > 630) begin
				paint_r = 8'b11110000;
				paint_g = 8'b11110000;
				paint_b = 8'b11110000;
			 end
			 else begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			 end
			 end
			default: begin
				paint_r = {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
				paint_g = {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
				paint_b = {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
			end
		 endcase
		end
		else begin
		 paint_r = (drawing_t1) ? {spr_pix_colr[COLRW - 1 : COLRW - CHANW], 4'b0000} : {BG_COLR[COLRW - 1 : COLRW - CHANW], 4'b0000};
		 paint_g = (drawing_t1) ? {spr_pix_colr[COLRW - 1 - CHANW : COLRW - 2*CHANW], 4'b0000} : {BG_COLR[COLRW - 1 - CHANW: COLRW - 2*CHANW], 4'b0000};
		 paint_b = (drawing_t1) ? {spr_pix_colr[COLRW - 1 - 2*CHANW : COLRW - 3*CHANW], 4'b0000} : {BG_COLR[COLRW - 1 - 2*CHANW: COLRW - 3 *CHANW], 4'b0000};
		end
	 end

    // display colour: paint colour but black in blanking interval
    reg [7:0] display_r, display_g, display_b;
    always @(*) begin
        display_r = (blank_n) ? paint_r : 8'b00000000;
        display_g = (blank_n) ? paint_g : 8'b00000000;
        display_b = (blank_n) ? paint_b : 8'b00000000;
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
