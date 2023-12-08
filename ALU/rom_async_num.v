module rom_async_num #(
	parameter WIDTH=8,
	parameter DEPTH=8,
	parameter INIT_F=""
	 
	) (
	
	input clk,
	input [3:0] number,
	input [$clog2(DEPTH)-1:0] addr,
	output reg [WIDTH-1:0] data
	);
	 
	mux16 #(16) 
	mux10 (
		.selection(number),
		.input_1()
	);
	 
	reg [WIDTH-1:0] memory [DEPTH-1:0];
	
	initial begin
		$display("Creating rom_async from init file '%s'.", INIT_F);
		$readmemh(INIT_F, memory);
	end
	
	always @(posedge clk) begin 
		data <= memory[addr];
	end
endmodule
