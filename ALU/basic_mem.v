module basic_mem #(
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
	
	output reg [WIDTH - 1 : 0] q_a,
	output reg [WIDTH - 1 : 0] q_b
	);

	// Declare the RAM variable
	reg [WIDTH - 1 : 0] ram[2 ** WIDTH - 1 : 0];
	
	initial begin
	$display("Loading memory");
	$readmemh("memory.dat", ram);
	$display("done loading");
	end

	// Port A 
	always @ (posedge clk) begin
		//if(~reset) q_a <= 0;
		/*else*/ q_a <= ram[addr_a];
	end 

	// Port B 
	always @ (negedge clk) begin
		//if(~reset) q_b <= 0;

			if (we_b) begin
				ram[addr_b] <= data_b;
				q_b <= data_b;
			end
			else q_b <= ram[addr_b];
	end

endmodule
