module Datapath #(parameter WIDTH = 16, REGBITS = 5)(
					input [5:0] alucont, input [REGBITS-1:0] ra1, input [REGBITS-1:0] ra2,
					input regwrite, input clk, output[WIDTH-1:0] result, output[WIDTH-1:0] psr_flags
					);
wire [WIDTH-1:0] wd,rd1,rd2;
assign result = wd;
regfile    #(WIDTH,REGBITS) rf(clk, regwrite, ra1, ra2, wd, rd1, rd2);
alu_rf 		 alunit(rd1,rd2,alucont,wd,psr_flags);
endmodule
