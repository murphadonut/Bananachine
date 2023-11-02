module datapathFSMTB ( );

reg clk;
//1 bit reg
reg reg_write, pc_en, alu_A_src, pc_src, alu_B_src;
reg [1:0] reg_write_src;

//alu control
reg[5:0] alu_cont;

// instructions to datapath
reg [15:0] inst;

//wires to interact with data to and from memory
wire[15:0] pc,psr_flags,mem_address,data_to_mem,data_from_mem;
wire[3:0] op_code,ext_op_code,A_index,B_index;

//write enable for memory
reg wren_a;

//exmem module b data entries are just dummy wires for now
basic_mem exmem(
						.addr_a(mem_address),
						.clk(clk),
						.data_a(data_to_mem),
						.we_a(wren_a),
						.q_a(data_from_mem)
						
						
);



datapath d(
				.clk(clk),
				.reset(reset),
				.reg_write(reg_write),
				.alu_A_src(alu_A_src),
				.alu_B_src(alu_B_src),
				.reg_write_src(reg_write_src),
				.alu_cont(alu_cont),
				.data_from_mem_load(data_from_mem),
				.mem_address_load_stor(mem_address),
				.data_to_mem_stor(data_to_mem),
				.op_code(op_code),
				.ext_op_code(ext_op_code),
				.A_index(A_index),
				.B_index(B_index),
				.data_from_mem_PC(inst)
				
);

initial begin
#5
clk =0;
	
	//load 3

	reg_write <= 0;
	reg_write_src = 0;
	alu_A_src <= 0;
	alu_B_src <= 1;
	inst <= 16'b0000000100000011;
	alu_cont <= 6'b111111;
	 #5
clk =1;
	
	//write 3 to register 1
	#5
clk =0;
	reg_write <= 1;
	#5
	clk =1;
	
	//load 2
	#5
	clk = 0;
	reg_write <= 0;
	inst <= 16'b0000001000000010;
	alu_cont <= 6'b111111;
	#5
clk=1;
	
	//write 2 to register 2
	#5
clk =0;

	reg_write <= 1;
	#5
clk =1;
	
	//add registers 1 and 2
	#5 
	clk =0;
	reg_write <= 0;
	alu_A_src <= 1;
	alu_B_src <=0;
	inst <= 16'b0000000100000010;
	alu_cont <= 6'b000101;
	#5
	clk =1;
	#5
	clk =0;
	#5
	clk =1;
	
	//store value into register 1 should be 5
	#5
	clk=0;
	reg_write <= 1;
	reg_write_src <= 0;
	#5
	clk =1;
	
	//store value in memory location 4
	#5
	clk =0;
	reg_write <= 0;
	alu_A_src <= 1;
	alu_B_src <=1;
	inst <= 16'b0000000100000100;
	#5
	clk =1;
	
	// write value in memory
	#5
	clk =0;
	wren_a <= 1;
	#5
	clk =1;
	
	//load value in memory location 4
	#5
	clk =0;
	reg_write_src <= 1;
	#5
	clk =1;
	
	//write value into register a which is register 4
	#5
	clk =0;
	inst <= 16'b0000001100000000;
	reg_write <= 1;
	#5
	clk =1;
	#5
	clk =0;

	end
endmodule 