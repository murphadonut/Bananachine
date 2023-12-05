module bananachine #(
	parameter WIDTH = 16, 
	parameter REG_BITS = 4, 
	parameter OP_CODE_BITS = 4, 
	parameter EXT_OP_CODE_BITS = 4, 
	parameter ALU_CONT_BITS = 6,
	parameter H_RES = 640,
	parameter V_RES = 480,
	parameter COUNTER_BITS = 10,
	parameter[15:0] MXP = 6000, 
	parameter[15:0] MYP = 6004, 
	parameter[15:0] P1XP = 6008, 
	parameter[15:0] P1YP = 6012, 
	parameter[15:0] P2XP = 6016, 
	parameter[15:0] P2YP = 6020
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
	wire [WIDTH-1:0] data_from_mem;
	wire [WIDTH-1:0] data_from_mem_vga;
	wire [WIDTH-1:0] mem_address;
	wire [WIDTH-1:0] data_to_mem_store;
	wire [WIDTH-1:0] vga_address;
	wire [15:0] mx;
	
	reg mx_en;
	reg my_en;
	
	reg[15:0] my; 
	reg[15:0] p1x; 
	reg[15:0] p1y; 
	reg[15:0] p2x; 
	reg[15:0] p2y;
	
	wire[2:0] vga_counter;
	
	vga_counter vga_counter_i(
		.clk(clk),
		.reset(reset),
		.counter(vga_counter)
	);
	
	mux8 #(WIDTH) mux8_i(
		.selection(vga_counter),
		.input_1(MXP),
		.input_2(MYP),
		.input_3(P1XP),
		.input_4(P1YP),
		.input_5(P2XP),
		.input_6(P2YP),
		.input_7(),
		.input_8(),
		.mux8_output(vga_address)		
	);
	
	flopenr #(WIDTH) mx_reg (
		.clk(clk),
		.reset(reset),
		.en(mx_en),
		.d(data_from_mem_vga),
		.q(mx)
	);
	
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
		.addr_a(vga_address), 
		.addr_b(mem_address),
		.we_b(write_to_memory), 
		.clk(clk),
		.reset(reset),
		.reading_for_load(reading_for_load),
		.q_a(data_from_mem_vga), 
		.q_b(data_from_mem),
		.start(start),
		.left(left),
		.right(right)
	);
	
	vga #(H_RES, V_RES, COUNTER_BITS) vga(
		.clk_50MHz(clk),
		.clear(reset),
		.vga_counter(vga_counter),
		.data_from_mem_vga(data_from_mem_vga),
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