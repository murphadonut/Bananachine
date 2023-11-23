module Bananachine #(parameter WIDTH = 16, REG_BITS = 4, OP_CODE_BITS = 4, EXT_OP_CODE_BITS = 4, ALU_CONT_BITS = 6)(
		input clk, reset, left, right, start
	);

	wire write_to_memory, reading_for_load;
	wire [WIDTH - 1 : 0] data_from_mem, mem_address, data_to_mem_store;

	
	CPU #(WIDTH) cpu(
		.clk(clk), 
		.reset(reset),
		.data_from_mem(data_from_mem),
		.write_to_memory(write_to_memory),
		.reading_for_load(reading_for_load),
		.mem_address(mem_address),  
		.data_to_mem_store(data_to_mem_store)
	);
	
	basic_mem #(WIDTH)
		mem( 
		//.data_a(),
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
	
endmodule 