// Good
module vga_counter (
	input clk, 
	input reset,
	input [15:0] data_from_mem_vga,
	
	output reg [2:0] counter,
	output reg [15:0] mx,
	output reg [15:0] my,
	output reg [15:0] p1x,
	output reg [15:0] p1y,
	output reg [15:0] p2x,
	output reg [15:0] p2y,
	output reg [15:0] cont
	);


	always @(posedge clk) begin
		if(~reset) begin
			counter <= 0;
			mx <= 0;
			my <= 0;
			p1x <= 0;
			p1y <= 0;
			p2x <= 0;
			p2y <= 0;
			cont <= 0;
		end
		else begin
			case(counter)
				3'b001: mx <= data_from_mem_vga-32;
				3'b010: my <= data_from_mem_vga;
				3'b011: p1x <= data_from_mem_vga-32;
				3'b100: p1y <= data_from_mem_vga;
				3'b101: p2x <= data_from_mem_vga-32;
				3'b110: p2y <= data_from_mem_vga;
				3'b111: cont <= data_from_mem_vga;
				default:;
			endcase
		 if(counter == 3'b111) counter <= 0;
		 else	counter <= counter + 1'b1;
		end
	end
	
endmodule 