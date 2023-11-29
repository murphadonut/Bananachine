module reg_file #(
	parameter WIDTH = 16, 
	parameter REG_BITS = 4)(
	
	input		clk, 								// Controls when interactions with memory happen, on rising clock edge
	input		reg_write,						// Enable writing data to register?
	input		[REG_BITS - 1:0] A_index, 	// Current register we are to output to A_data
	input		[REG_BITS - 1:0] B_index,  // Current register we are to output to B_data
	input		[WIDTH - 1:0] write_data, 	// Whats getting written to register A
	
	output	[WIDTH - 1:0] A_data, 		// Data stored in register A
	output	[WIDTH - 1:0] B_data			// Data stored in register B
	);

   reg  [WIDTH-1:0] RAM [(1<<REG_BITS)-1:0];
	
	// Load register file change file location
	initial begin
		$display("Loading register file");
		$readmemb("reg.dat", RAM); 
		$display("done with RF load"); 
	end

   // Dual-ported register file
   // Read two ports combinationally
   // Write third port on rising edge of clock
   always @(posedge clk)
      if (reg_write) RAM[A_index] <= write_data;
	
   // Register 0 is hardwired to 0
   assign A_data = A_index ? RAM[A_index] : 1'b0;
   assign B_data = B_index ? RAM[B_index] : 1'b0;
endmodule
