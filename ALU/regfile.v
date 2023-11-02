//width is 16 as registers are 16 bits
//regbits is 5 as there are 17 registers
module regfile #(parameter WIDTH = 16, REGBITS = 5)
                (input                clk, 
                 input                regwrite, 
                 input  [REGBITS-1:0] ra1, ra2, 
                 input  [WIDTH-1:0]   wd, 
                 output [WIDTH-1:0]   rd1, rd2);

   reg  [WIDTH-1:0] RAM [(1<<REGBITS)-1:0];
	
	initial begin
	$display("Loading register file");
	// you'll need to change the path to this file! 
	$readmemb("Reg.dat", RAM); 
	$display("done with RF load"); 
	end

<<<<<<< Updated upstream
   // dual-ported register file
   //   read two ports combinationally
   //   write third port on rising edge of clock
   always @(posedge clk)
      if (regwrite) RAM[ra1] <= wd;
=======
   // Dual-ported register file
   // Read two ports combinationally
   // Write third port on rising edge of clock
   always @(negedge clk)
      if (reg_write) RAM[A_index] <= write_data;
>>>>>>> Stashed changes
	
   // register 0 is hardwired to 0
   assign rd1 = ra1 ? RAM[ra1] : 0;
   assign rd2 = ra2 ? RAM[ra2] : 0;
endmodule
