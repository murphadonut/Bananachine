// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module basic_mem
#(parameter WIDTH = 16)
(
	input [WIDTH - 1 : 0] data_a, data_b,
	input [WIDTH - 1 : 0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [WIDTH - 1 : 0] q_a, q_b
);

	// Declare the RAM variable
	reg [WIDTH - 1 : 0] ram[2 ** WIDTH - 1 : 0];
	
	initial begin
	$display("Loading memory");
	$readmemb("memory.dat", ram);
	$display("done loading");
	end

	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end

endmodule
