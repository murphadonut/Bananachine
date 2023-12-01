module bananachine #(
	parameter WIDTH = 16, 
	parameter REG_BITS = 4, 
	parameter OP_CODE_BITS = 4, 
	parameter EXT_OP_CODE_BITS = 4, 
	parameter ALU_CONT_BITS = 6,
	parameter H_RES = 640,
	parameter V_RES = 480,
	parameter COUNTER_BITS = 10,
	parameter MX = 6000, 
	parameter MY = 6004, 
	parameter P1X = 6008, 
	parameter P1Y = 6012, 
	parameter P2X = 6016, 
	parameter P2Y = 6020
	) (
	
	input clk, 
	input reset, 
	input left, 
	input right, 
	input start,
	
	output vga_clk,
	output vga_h_sync,
	output vga_v_sync,
	output vga_sync,
	output vga_blank,
	output [7:0] vga_red,
	output [7:0] vga_green,
	output [7:0] vga_blue
	);

	wire write_to_memory;
	wire reading_for_load;
	wire [WIDTH - 1 : 0] data_from_mem;
	wire [WIDTH - 1 : 0] mem_address;
	wire [WIDTH - 1 : 0] data_to_mem_store;

	
	cpu #(WIDTH) cpu(
		.clk(clk), 
		.reset(reset),
		.data_from_mem(data_from_mem),
		.write_to_memory(write_to_memory),
		.reading_for_load(reading_for_load),
		.mem_address(mem_address),  
		.data_to_mem_store(data_to_mem_store)
	);
	
	basic_mem #(WIDTH) mem( 
		.data_b(data_to_mem_store),
		//.addr_a(), 
		.addr_b(mem_address),
		//.we_a(),
		.we_b(write_to_memory), 
		.clk(clk),
		.reset(reset),
		.reading_for_load(reading_for_load),
		//.q_a(), 
		.q_b(data_from_mem),
		//start
		.start(start),
		//left
		.left(left),
		//right
		.right(right)
	);
	
	vga #(H_RES, V_RES, COUNTER_BITS, MX, MY, P1X, P1Y, P2X, P2Y) vga(
		.clk_50MHz(clk),
		.clear(reset),
		.clk_25MHz(vga_clk),
		.h_sync(vga_h_sync),
		.v_sync(vga_v_sync),
		.sync_n(vga_sync),
		.blank_n(vga_blank),
		.red_out(vga_red),
		.green_out(vga_green),
		.blue_out(vga_blue)
	);
	
endmodule 