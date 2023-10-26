module regfile #(parameter WIDTH = 16, REG_BITS = 5)( // REGBITS is 5 as there are 17 registers
	input		clk, reg_write,
	input		[REG_BITS - 1:0] A_index, B_index, write_index, 
	input		[WIDTH - 1:0]   write_data, 
	output	[WIDTH - 1:0]   A_data, B_data
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
      if (reg_write) RAM[write_index] <= write_data;
	
   // Register 0 is hardwired to 0
   assign A_data = A_index ? RAM[A_index] : 0;
   assign B_data = B_index ? RAM[B_index] : 0;
endmodule
