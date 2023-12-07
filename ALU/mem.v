module mem #(
	parameter WIDTH = 16) (
	
	input we_b, 
	input clk, 
	input reset, 
	input reading_for_load,
	input left,
	input right,
	input start,
	input [WIDTH - 1 : 0] data_b,
	input [WIDTH - 1 : 0] addr_a,
	input [WIDTH - 1 : 0] addr_b, 
	
	output [WIDTH - 1 : 0] q_a,
	output reg [WIDTH - 1 : 0] q_b,
	output [WIDTH - 1 : 0] memdata
	);
	basic_mem mem(
	.we_b(we_b),
	.clk(clk),
	.reset(reset),
	.reading_for_load(reading_for_load),
	.data_b(data_b),
	.addr_a(addr_a),
	.addr_b(addr_b),
	.q_a(q_a),
	.q_b(memdata)
	);
	always @ (posedge clk) begin
		//if(~reset) q_a <= 0;
		/*else*/
		if(~we_b)begin
			if(addr_b ==65535) begin
			//q_b <= 16'b0000000000000001;
				if(~start) begin
				q_b <= 16'b0000000000000001;
				end
				else if(~left) begin
				q_b <= 16'b0000000000000010;
				end
				else if(~right) begin
				q_b <= 16'b0000000000000011;
				end
				else begin
				q_b <= 16'b0000000000000000;
				end
			end
			else begin
			q_b <= memdata;
			end
		end 
		end

endmodule
