module BitGen (
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
    wire de, frame, line;
	 
	 vga_control control(
		.clk_50MHz(clk_50m),
		.clear(btn_rst_n),
		.bright(bright), 
		.h_sync(hsync), 
		.v_sync(vsync), 
		.clk_25MHz(clk_25MHz),
		.h_count(sx), 
		.v_count(sy),
		.de(de),       // data enable (low in blanking interval)
		.frame(frame),    // high at start of frame
		.line(line) 		 // high at start of line
	);

    // screen dimensions (must match display_inst)
    localparam H_RES = 640;
    localparam V_RES = 480;

    // sprite parameters
    localparam SPR_WIDTH  = 8;  // bitmap width in pixels
    localparam SPR_HEIGHT = 8;  // bitmap height in pixels
    localparam SPR_SCALE  = 3;  // 2^3 = 8x scale
    localparam SPR_DATAW  = 1;  // bits per pixel
    localparam SPR_DRAWW  = SPR_WIDTH  * 2**SPR_SCALE;  // draw width
    localparam SPR_DRAWH  = SPR_HEIGHT * 2**SPR_SCALE;  // draw height
    localparam SPR_SPX    = 4;  // horizontal speed (pixels/frame)
    localparam SPR_FILE   = "letter_f.mem";  // bitmap file

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

    // paint colour: yellow sprite, blue background
    reg [7:0] paint_r, paint_g, paint_b;
    always @(*) begin
        paint_r = (drawing && pix) ? 8'b11111111 : 8'b00001111;
        paint_g = (drawing && pix) ? 8'b11111111 : 8'b00001111;
        paint_b = (drawing && pix) ? 8'b00001111 : 8'b11110000;
    end

    // display colour: paint colour but black in blanking interval
    reg [7:0] display_r, display_g, display_b;
    always @(*) begin
        display_r = (de) ? paint_r : 8'b00000000;
        display_g = (de) ? paint_g : 8'b00000000;
        display_b = (de) ? paint_b : 8'b00000000;
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
