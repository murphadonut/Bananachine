module vga_counter (
	input clk, reset,
	output reg [2:0] counter
);


// might not like this, if so, change to assign, should still work
	always @(negedge clk)
	begin
		if(~reset) 
			begin
				counter <= 0;
			end
		else begin
<<<<<<< Updated upstream
		 if(counter >= 3'b101) counter <= 0;
=======
			case(counter)
				3'b001: mx <= data_from_mem_vga-32;
				3'b010: my <= data_from_mem_vga;
				3'b011: p1x <= data_from_mem_vga-32;
				3'b100: p1y <= data_from_mem_vga;
				3'b101: p2x <= data_from_mem_vga-32;
				3'b110: p2y <= data_from_mem_vga;
				default:;
			endcase
		 if(counter == 3'b110) counter <= 0;
>>>>>>> Stashed changes
		 else	counter <= counter + 1'b1;
		end
	end
	
endmodule 