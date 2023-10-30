module Bananachine #(parameter WIDTH = 16)(
		input clk, reset
	);

	wire write_to_memory;
	wire [WIDTH - 1 : 0] data_from_mem_PC, data_from_mem_load, mem_address_PC, mem_address_load_stor, data_to_mem_stor;

	
	CPU cpu(
		.clk(clk), 
		.reset(reset),
		.data_from_mem_PC(data_from_mem_PC), 
		.data_from_mem_load(data_from_mem_load),
		.write_to_memory(write_to_memory),
		.mem_address_PC(mem_address_PC), 
		.mem_address_load_stor(mem_address_load_stor), 
		.data_to_mem_stor(data_to_mem_stor)
	);
	
	basic_mem mem(
		.data_a(), 
		.data_b(data_to_mem_stor),
		.addr_a(mem_address_PC), 
		.addr_b(mem_address_load_stor),
		.we_a(), 
		.we_b(write_to_memory), 
		.clk(clk),
		.q_a(data_from_mem_PC), 
		.q_b(data_from_mem_load)
	);
	
endmodule 