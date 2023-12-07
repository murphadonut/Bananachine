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
		 if(counter >= 3'b101) counter <= 0;
		 else	counter <= counter + 1'b1;
		end
	end
	
endmodule 