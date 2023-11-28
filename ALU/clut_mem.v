module clut_mem #(
	parameter COLOR_BITS = 4, 
	parameter NUM_OF_COLORS = 16, 
	parameter LINE_SIZE = 3) (
	
	input we, 
	input clk_read, 
	input clk_write,
	input [COLOR_BITS * LINE_SIZE - 1 : 0] data_in,
	input [COLOR_BITS - 1 : 0] addr_read, 
	input [COLOR_BITS - 1 : 0] addr_write,
	
	output reg 	[COLOR_BITS * LINE_SIZE - 1 : 0] data_out
	
);
			
	// Each spot of memory, aka, word, is 12 bits, four bits for each of the colors, r, g, b
	// Then, we've got 16 different colors
	reg [COLOR_BITS * LINE_SIZE - 1 : 0] ram[NUM_OF_COLORS - 1:0];
	
	// Load the color pallet file, will be different for everyone
	initial begin
		$display("Loading color pallete");
		$readmemh("teleport16_4b.mem", ram);
		$display("done loading");
    end
	
	// Write
	always @ (posedge clk_write) begin
		if (we) ram[addr_write] <= data_in;
	end
	
	// Read
	always @ (posedge clk_read) data_out <= ram[addr_read];
	
endmodule
