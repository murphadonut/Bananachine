module pc_counter #(parameter WIDTH = 16) (
	input clk, reset, 
	input [WIDTH - 1 : 0] current_pc,
	output reg [WIDTH - 1 : 0] incremented_pc
);


// might not like this, if so, change to assign, should still work
	always @(posedge clk)
	begin
		if(~reset) 
			begin
				incremented_pc <= 0;
			end
		incremented_pc <= current_pc + WIDTH;
	end
	
endmodule 