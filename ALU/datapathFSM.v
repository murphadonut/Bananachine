module datapathFSM (input clk, reset,butt,output reg[7:0] addr, output[6:0] read, write,st);


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
reg[3:0] x;
//data display for readData
hexTo7Seg readData( x , write);
//display for the data_to_mem this is set to hex [1] 
hexTo7Seg writeData( data_to_mem , read);
//displays state to the hex [0]
hexTo7Seg stateDisplay(state, st);
//instantiate datapath
datapath d(reg_write, clk, reset, 1, alu_A_src, 1, reg_write_src, destination_reg, alu_B_src,alu_cont,inst,pc,psr_flags,data_to_mem);
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
	load : unclockedNextState <= load;
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
	//load 3 into register 1
	li1:begin
	reg_write <= 0;
	alu_A_src <= 0;
	alu_B_src <= 1;
	inst <= 16'b0000000100000011;
	alu_cont <= 5'b01000;
	 addr <= 0;
	end
	//load 2 intorr register 2
		li2:begin
	reg_write <= 0;
	alu_A_src <= 0;
	alu_B_src <=1;
	inst <= 16'b0000001000000010;
	alu_cont <= 5'b01000;
	addr <= 0;
	end
	//add registers 1 and 2 store in 1
			add:begin
	reg_write <= 1;
	alu_A_src <= 1;
	alu_B_src <=0;
	inst <= 16'b0000000100000010;
	alu_cont <= 5'b00011;
	reg_write_src <= 0;
	addr <= 0;
	end
	//store value in memory location 4
				store:begin
	reg_write <= 0;
	alu_A_src <= 1;
	alu_B_src <=1;
	inst <= 16'b0000000100000100;
	alu_cont <= 5'b00011;
	addr <= 4;
	destination_reg <=0;
	end
	//load value in memory location 4
					load:begin
	reg_write <= 0;
	alu_A_src <= 1;
	alu_B_src <=1;
	inst <= 16'b0000000100000100;
	alu_cont <= 5'b00011;
	reg_write_src <= 0;
	addr <= 4;
	end

	default : begin
		reg_write <= 0;
	alu_A_src <= 0;
	alu_B_src <=1;
	inst <= 16'b0000000100000011;
	alu_cont <= 5'b01000;
	addr <= 0;
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
module hexTo7Seg(
		input [3:0]x,
		output reg [6:0]z
		);

  // always @* guarantees that the circuit that is 
  // synthesized is combinational 
  // (no clocks, registers, or latches)
  always @*
    // Note that the 7-segment displays on the DE1-SoC board are
    // "active low" - a 0 turns on the segment, and 1 turns it off
    case(x)
      4'b0000 : z = ~7'b0111111; // 0
      4'b0001 : z = ~7'b0000110; // 1
      4'b0010 : z = ~7'b1011011; // 2
      4'b0011 : z = ~7'b1001111; // 3
      4'b0100 : z = ~7'b1100110; // 4
      4'b0101 : z = ~7'b1101101; // 5
      4'b0110 : z = ~7'b1111101; // 6
      4'b0111 : z = ~7'b0000111; // 7
      4'b1000 : z = ~7'b1111111; // 8
      4'b1001 : z = ~7'b1100111; // 9 
      4'b1010 : z = ~7'b1110111; // A
      4'b1011 : z = ~7'b1111100; // b
      4'b1100 : z = ~7'b1011000; // c
      4'b1101 : z = ~7'b1011110; // d
      4'b1110 : z = ~7'b1111001; // E
      4'b1111 : z = ~7'b1110001; // F
      default : z = ~7'b0000000; // Always good to have a default! 
    endcase
endmodule 