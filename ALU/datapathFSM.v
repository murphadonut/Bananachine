module datapathFSM (input clk, reset,butt,output[7:0] addr, output[6:0] read, write);


reg [5:0] state,unclockedNextState;
wire[5:0]nextState;
//set parameters
parameter [2:0] li1 = 3'b000;
parameter [2:0] li2 = 3'b001;
parameter [2:0] add = 3'b010;
parameter [2:0] store = 3'b011;
parameter [2:0] load= 3'b100;



	// Flip-flop to hold the next state
flipflop #(.size(3))
ff(.clk(~butt), .rst(reset), .d(unclockedNextState), .q(nextState));
reg reg_write, pc_en, alu_A_src, pc_src, reg_write_src, destination_reg;
reg[1:0] alu_B_src;
reg[4:0] alu_cont;
reg [15:0] inst, data_from_mem;
wire[15:0] data_to_mem,pc,psr_flags;


datapath d(reg_write, clk, reset, 1, alu_A_src, pc_src, reg_write_src, destination_reg, alu_Bsrc,alu_cont,inst,pc,psr_flags,data_to_mem);
//set the next state values
always@(posedge clk, negedge reset)
	begin
	//handles reset
	if(reset ==0) unclockedNextState <= li1;
	case(state)
	li1 : unclockedNextState <= li2;
	li2 : unclockedNextState <= add;
	add : unclockedNextState <= store;
	store : unclockedNextState <= load;
	default unclockedNextState <= li1;

	endcase
	end
	//set state to nextstate 
	always@(*)
	begin
			state = nextState;
	end
//set the outputs bases on the current state
always@(state)
	begin
	case(state)
	li1:begin
	reg_write = 0;
	alu_A_src = 0;
	alu_B_src =1;
	inst = 16'b0000000100000011;
	alu_cont = 5'b01000;
	addr = 0;
	end
		li2:begin
	reg_write = 0;
	alu_A_src = 0;
	alu_B_src =1;
	inst = 16'b0000001000000010;
	alu_cont = 5'b01000;
	addr = 0;
	end
			add:begin
	reg_write = 1;
	alu_A_src = 1;
	alu_B_src =0;
	inst = 16'b0000000100000010;
	alu_cont = 5'b00011;
	addr = 0;
	end
				store:begin
	reg_write = 0;
	alu_A_src = 1;
	alu_B_src =1;
	inst = 16'b0000000100000100;
	alu_cont = 5'b00011;
	addr = 4;
	end
	default : begin
		reg_write = 0;
	alu_A_src = 0;
	alu_B_src =1;
	inst = 16'b0000000100000011;
	alu_cont = 5'b01000;
	addr = 0;
	end
endcase

	end
endmodule

// Flip-flop Module
module flipflop #(parameter size = 1) (
input wire clk, // Clock signal
input wire rst, // Reset signal (active-low)
input wire [size-1:0] d, // Data input
output reg [size-1:0] q // Data output
);
// Flip-flop behavior
always @(posedge clk, negedge rst) begin
if (!rst) q <= {size{1'b0}}; // If reset, output 0
else q <= d; // Otherwise, output the data input
end
endmodule