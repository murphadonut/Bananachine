module Bananachine #(parameter WIDTH = 16, REG_BITS = 4, OP_CODE_BITS = 4, EXT_OP_CODE_BITS = 4, ALU_CONT_BITS = 6)(
		input clk, reset
	);

	wire write_to_memory, reading_for_load;
	wire [WIDTH - 1 : 0] data_from_mem_PC, data_from_mem_load, mem_address_PC, mem_address_load_stor, data_to_mem_stor;

	
	CPU #(WIDTH) cpu(
		.clk(clk), 
		.reset(reset),
		.data_from_mem_PC(data_from_mem_PC), 
		.data_from_mem_load(data_from_mem_load),
		.write_to_memory(write_to_memory),
		.reading_for_load(reading_for_load),
		.mem_address_PC(mem_address_PC), 
		.mem_address_load_stor(mem_address_load_stor), 
		.data_to_mem_stor(data_to_mem_stor)
	);
	
	basic_mem #(WIDTH)
		mem( 
		.data_b(data_to_mem_stor),
		.addr_a(mem_address_PC), 
		.addr_b(mem_address_load_stor),
		.we_b(write_to_memory), 
		.clk(clk),
		.reset(reset),
		.reading_for_load(reading_for_load),
		.q_a(data_from_mem_PC), 
		.q_b(data_from_mem_load)
	);
	
endmodule 