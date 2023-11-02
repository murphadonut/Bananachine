module datapathFSM (input clk, reset,butt,output reg[7:0] addr, output[6:0] read, write,st);


reg [5:0] state,unclockedNextState;
wire[5:0]nextState;
//set parameters
parameter [3:0] li1rd = 4'b1010;
parameter [3:0] li1wr = 4'b0001;
parameter [3:0] li2rd = 4'b0010;
parameter [3:0] li2wr = 4'b0011;
parameter [3:0] addex = 4'b0100;
parameter [3:0] addwr = 4'b0101;
parameter [3:0] storeex = 4'b0110;
parameter [3:0] storewr = 4'b0111;
parameter [3:0] loadre= 4'b1000;
parameter [3:0] loadwr= 4'b1001;
parameter [3:0] res= 4'b0000;


	// Flip-flop to hold the next state
flipflop #(.size(4))
ff(.clk(~butt), .rst(reset), .d(unclockedNextState), .q(nextState));
//1 bit reg
reg reg_write, pc_en, alu_A_src, pc_src, alu_B_src;
reg [1:0] reg_write_src;

//alu control
reg[5:0] alu_cont;

// instructions to datapath
reg [15:0] inst;

//wires to interact with data to and from memory
wire[15:0] pc,psr_flags,mem_address,data_to_mem,data_from_mem;
wire[3:0] op_code,ext_op_code,A_index,B_index;
//write enable for memory
reg wren_a;

//exmem module b data entries are just dummy wires for now
basic_mem exmem(
						.addr_a(mem_address),
						.clk(butt),
						.data_a(data_to_mem),
						.we_a(wren_a),
						.q_a(data_from_mem)
						
						
);

//data display for readData set to hex[2]
hexTo7Seg readData(  data_from_mem [11:8], write);

//display for the data_to_mem this is set to hex [1] 
hexTo7Seg writeData( data_to_mem [11:8] , read);

//displays state to the hex [0]
hexTo7Seg stateDisplay(state, st);

//instantiate datapath, datapath's clock is set to button presses
datapath d(
				.clk(butt),
				.reset(reset),
				.reg_write(reg_write),
				.alu_A_src(alu_A_src),
				.alu_B_src(alu_B_src),
				.reg_write_src(reg_write_src),
				.alu_cont(alu_cont),
				.data_from_mem_load(data_from_mem),
				.mem_address_load_stor(mem_address),
				.data_to_mem_stor(data_to_mem),
				.op_code(op_code),
				.ext_op_code(ext_op_code),
				.A_index(A_index),
				.B_index(B_index),
				.data_from_mem_PC(inst)
				
);
//set the next state values
always@(posedge clk, negedge reset)
	begin
	//handles reset
<<<<<<< Updated upstream
	if(reset ==0) unclockedNextState <= li1wr;
=======
	if(~reset) unclockedNextState <= res;
>>>>>>> Stashed changes
	case(state)
	res : unclockedNextState <= li1rd;
	
	li1rd : unclockedNextState <= li1wr;
	
	li1wr : unclockedNextState <= li2rd;
	
	li2rd : unclockedNextState <= li2wr;
	
	li2wr : unclockedNextState <= addex;
	
	addex : unclockedNextState <= addwr;
	
	addwr : unclockedNextState <= storeex;
	
	storeex : unclockedNextState <= storewr;
	
	storewr : unclockedNextState <= loadre;
	
	loadre : unclockedNextState <= loadwr;

	default unclockedNextState <= res;

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
	res:begin
	reg_write <=0;
	wren_a <=0;
	end
	
	//load 3
	li1rd:begin
	reg_write <= 0;
	reg_write_src = 0;
	alu_A_src <= 0;
	alu_B_src <= 1;
	inst <= 16'b0000000100000011;
	alu_cont <= 6'b111111;
	end
	
	//write 3 to register 1
		li1wr:begin
	reg_write <= 1;
	end
	
	//load 2
		li2rd:begin
	reg_write <= 0;
	inst <= 16'b0000001000000011;
	alu_cont <= 6'b111111;
	end
	
	//write 2 to register 2
			li2wr:begin
	reg_write <= 1;
	end
	
	//add registers 1 and 2
			addex:begin
	reg_write <= 0;
	alu_A_src <= 1;
	alu_B_src <=0;
	inst <= 16'b0000000100000010;
	alu_cont <= 6'b000101;
	end
	
	//store value into register 1 should be 5
				addwr:begin
	reg_write <= 1;
	reg_write_src <= 0;
	end
	
	//store value in memory location 4
				storeex:begin
	reg_write <= 0;
	alu_A_src <= 1;
	alu_B_src <=1;
	inst <= 16'b0000000100000100;
	end
	
	// write value in memory
				storewr:begin
	wren_a <= 1;
	end
	
	//load value in memory location 4
				loadre:begin
	wren_a <= 0;
	reg_write_src <= 1;
	end
	
	//write value into register a which is register 4
				loadwr:begin
	inst <= 16'b0000001100000000;
	reg_write <= 1;
	end

	//empty default case
	default : begin

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