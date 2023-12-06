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
	wire [15:0] data_from_mem;
	wire [15:0] data_from_mem_vga;
	wire [15:0] mem_address;
	wire [15:0] data_to_mem_store;
	wire [15:0] vga_address;
	wire [15:0] mx;
	wire [15:0] my; 
	wire [15:0] p1x; 
	wire [15:0] p1y; 
	wire [15:0] p2x; 
	wire [15:0] p2y;
	wire[2:0] vga_counter;
	
	wire [15:0] something;
	
	assign something = mem_address == 16'b1111111111111111 ? (~start == 0 ? 1'b1 : 0) : data_from_mem;
	
	vga_counter vga_counter_i(
		.clk(clk),
		.reset(reset),
		.data_from_mem_vga(data_from_mem_vga),
		.counter(vga_counter),
		.mx(mx),
		.my(my),
		.p1x(p1x),
		.p1y(p1y),
		.p2x(p2x),
		.p2y(p2y)
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
	
//	ram ram(
//		.address_a(vga_address),
//		.address_b(mem_address),
//		.clock(clk),
//		.data_a(),
//		.data_b(data_to_mem_store),
//		.wren_a(),
//		.wren_b(write_to_memory),
//		.q_a(data_from_mem_vga),
//		.q_b(data_from_mem)
//	);
	
	true_dual_port_ram_single_clock #(WIDTH, WIDTH) new_mem (
		.data_a(), 
		.data_b(data_to_mem_store),
		.addr_a(vga_address), 
		.addr_b(mem_address),
		.we_a(), 
		.we_b(write_to_memory), 
		.clk(clk),
		.q_a(data_from_mem_vga), 
		.q_b(data_from_mem)
	);
	
	cpu #(WIDTH) cpu(
		.clk(clk), 
		.reset(reset),
		.data_from_mem(something),
		.write_to_memory(write_to_memory),
		.reading_for_load(reading_for_load),
		.mem_address(mem_address),  
		.data_to_mem_store(data_to_mem_store)
	);
	
	vga vga(
		.clk(clk),
		.reset(reset),
		.mx(mx),
		.my(my),
		.p1x(p1x),
		.p1y(p1y),
		.p2x(p2x),
		.p2y(p2y),
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