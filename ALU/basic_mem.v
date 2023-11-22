// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module basic_mem
#(parameter WIDTH = 16)
(
	input [WIDTH - 1 : 0] data_b,
	input [WIDTH - 1 : 0] addr_a, addr_b,
	input we_b, clk, reset, reading_for_load,left,right,start,
	output reg [WIDTH - 1 : 0] q_a, q_b
);

	// Declare the RAM variable
	reg [WIDTH - 1 : 0] ram[2 ** WIDTH - 1 : 0];
	
	initial begin
	$display("Loading memory");
	$readmemh("memory.dat", ram);
	$display("done loading");
	end

	// Port A 
	always @ (posedge clk)
	begin
		if(~reset) q_a <= 0;
		else begin
			if(addr_a ==65535)begin
				if(~start)begin
				q_a <= 1;
				end
				else if(~left)begin
				q_a <= 2;
				end
				else if(~right)begin
				q_a <= 3;
				end
				else begin
				q_a <= 0;
				end
			end
			else begin
			q_a <= ram[addr_a];
			end
		end
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if(~reset) q_b <= 0;
		else
		begin
			if (we_b) 
			begin
				ram[addr_b] <= data_b;
				q_b <= data_b;
			end
			else q_b <= ram[addr_b];
		end
	end

endmodule
