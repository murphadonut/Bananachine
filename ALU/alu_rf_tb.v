`timescale 1ns / 1ps

module alu_rf_tb();

	reg clk, regwrite;
	reg[5:0] alucont;
	reg [4:0] ra1, ra2;
	wire[15:0] result, psr_flags;

	Datapath banana(alucont, ra1, ra2, regwrite, clk, result, psr_flags);

	initial
	begin
		regwrite = 0;
		alucont = 5'b00000;
		ra1 = 5'b0010; // register at index 4'b0010 (2) into a
		ra2 = 5'b0001; // register at idnex 4'b0001 (1) into b
		clk = 0;
		//test and
	#5
	clk =1;
	#5
	//test or
	clk = 0;
	alucont =5'b00001;
	#5
	clk =1;
	#5
	clk =0;
	alucont = 5'b00010;
	#5
	clk =1;
	#5
		//test add c flag
	clk =0;
	alucont =5'b00011;
	ra1 = 5'b00011;
	ra2 = 5'b00100;
	#5
	clk =1;
	#5
	clk =0;
	//test add no c flag set
	ra1 = 5'b0010;
	ra2 = 5'b0001;
	#5
	clk =1;
	#5 
	clk =0;
	//test F flag add set high end
	ra1 = 5'b00101;
	ra2 = 5'b00110;
	#5
	clk=1;
	#5
	clk =0;
	//test F flag add set low end
	ra1 = 5'b00011;
	ra2 = 5'b00111;
	#5
	clk =1;
	#5
	clk =0;
	//Test sub set C flag // WORKS 10/21/2023 MURPHY
	alucont = 5'b00100;
	ra1 = 5'b00100; // a reg 4 = 0000000000000010
	ra2 = 5'b00011; // b reg 3 = 1111111111111110
	#5
	clk =1;
	#5
	clk =0;
	//Test sub set F flag overflow positive side WORKS 10/21/2023
	ra1 = 5'b00101; // a reg 5 = 0111111111111111
	ra2 = 5'b00111; // b reg 7 = 1000000000000000
	#5
	clk =1;
	#5
	clk =0;
	//Test sub set F flag overflow negative side WORKS
	ra1 = 5'b00111; // a reg 7 = 1000000000000000
	ra2 = 5'b00101; // b reg 5 = 0111111111111111
	#5
	clk =1;
	#5
	clk =0;
	//Move
	alucont = 5'b00110; // WORKS 10/21/2023 BIG K
	ra1 = 5'b00100; // doesn't matter
	ra2 = 5'b00011; // b reg 3 = 1111111111111110
	#5
	clk =1;
	#5
	clk =0;
	//Shift Left
	alucont = 5'b00111;
	ra1 = 5'b00100; // a reg 4 = 0000000000000010
	ra2 = 5'b00110; // b reg 6 = 0000000000000001
	#5
	clk =1;
	#5
	clk =0;
	//Shift Right
	ra1 = 5'b00100; // a reg 4 = 0000000000000010
	ra2 = 5'b01001; // b reg 9 = 1111111111111111
	#5
	clk =1;
	#5
	clk =0;
	//LUI
	alucont = 5'b01000;
	ra1 = 5'b00100;
	ra2 = 5'b00110;
	#5
	clk =1;
	#5
	clk =0;
	//JCOND
	alucont = 5'b01001;
	ra1 = 5'b00100;
	ra2 = 5'b00110;
	#5
	clk =1;
	#5
	clk =0;
	//JAL
	alucont = 5'b01010;
	ra1 = 5'b00100;
	ra2 = 5'b00110;
	#5
	clk =1;
	#5
	clk =0;
	end
endmodule 