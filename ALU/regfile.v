module regfile #(parameter WIDTH = 16, REG_BITS = 5)( // REGBITS is 5 as there are 17 registers
	input		clk, reg_write, 
	input		[REG_BITS - 1:0] reg_A_index, reg_B_index, 
	input		[WIDTH - 1:0]   reg_write_data, 
	output	[WIDTH - 1:0]   reg_A_storage, reg_B_storage
	);

   reg  [WIDTH-1:0] RAM [(1<<REG_BITS)-1:0];
	
	// Load register file change file location
	initial begin
		$display("Loading register file");
		$readmemb("Reg.dat", RAM); 
		$display("done with RF load"); 
	end

   // Dual-ported register file
   // Read two ports combinationally
   // Write third port on rising edge of clock
   always @(posedge clk)
      if (reg_write) RAM[reg_A_index] <= reg_write_data;
	
   // Register 0 is hardwired to 0
   assign reg_A_storage = reg_A_index ? RAM[reg_A_index] : 0;
   assign reg_B_storage = reg_B_index ? RAM[reg_B_index] : 0;
endmodule
