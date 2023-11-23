module controller#(parameter WIDTH = 16, ALU_CONT_BITS = 6, REG_BITS = 4, OP_CODE_BITS = 4, EXT_OP_CODE_BITS = 4)(

	input clk, reset,
	input [OP_CODE_BITS - 1 : 0] 		op_code, 
	input [EXT_OP_CODE_BITS - 1 : 0] ext_op_code,
	input [REG_BITS - 1: 0] 			A_index, B_index,
	input [WIDTH - 1 : 0] 				psr_flags,
	
	output reg alu_A_src, alu_B_src, reg_write, write_to_memory, pc_en, loading, storing, instruction_en,
	output reg [1 : 0] 						pc_src, reg_write_src, 
	output reg [ALU_CONT_BITS - 1 : 0] 	alu_cont
	);
	
	// Conditions
	localparam EQ 		= 4'b0000;
	localparam NE		= 4'b0001;
	localparam GE		= 4'b1101;
	localparam CS		= 4'b0010;
	localparam CC		= 4'b0011;
	localparam HI		= 4'b0100;
	localparam LS		= 4'b0101;
	localparam LO		= 4'b1010;
	localparam HS		= 4'b1011;
	localparam GT		= 4'b0110;
	localparam LE		= 4'b0111;
	localparam FS		= 4'b1000;
	localparam FC		= 4'b1001;
	localparam LT		= 4'b1100;
	localparam UC		= 4'b1110;
	
	// Internal variables
	wire [14:0] conds;
	wire c_flag, f_flag, l_flag, z_flag, n_flag;
	
	assign c_flag						= psr_flags[0];
	assign f_flag						= psr_flags[5];
	assign l_flag						= psr_flags[2];
	assign z_flag						= psr_flags[6];
	assign n_flag						= psr_flags[7];
	
	assign conds[EQ] = z_flag;
	assign conds[NE] = ~z_flag;
	assign conds[GE] = n_flag || z_flag;
	assign conds[CS] = c_flag;
	assign conds[CC] = ~c_flag;
	assign conds[HI] = l_flag;
	assign conds[LS] = ~l_flag;
	assign conds[LO] = ~l_flag && ~z_flag;
	assign conds[HS] = l_flag || z_flag;
	assign conds[GT] = n_flag;
	assign conds[LE] = ~n_flag;
	assign conds[FS] = f_flag;
	assign conds[FC] = ~f_flag;
	assign conds[LT] = ~n_flag && ~z_flag;
	assign conds[UC] = 1'b1;
		
	// Used to differentiate between immediate alu instructions and non immediate alu instructions
	reg is_immediate;
	reg [7:0] state, next_state, previous_state;
	
	// These states are purely abstract, they use combos of 
	// op_code + ext_op_code that don't exist int the ISA handout
	localparam [7:0] NULL	= 8'b00001111;
	localparam [7:0] FETCH	= 8'b10001000;
	localparam [7:0] DECODE	= 8'b10001100;
	localparam [7:0] ALU_EX	= 8'b10000101;
	localparam [7:0] WRITE	= 8'b10001001;
	localparam [7:0] ALU		= 8'b10001110;
	localparam [7:0] LOAD2 	= 8'b10000111;
	
	// These states come straight from the ISA handout,
	// first four msb's are the op_code, followed by the ext_op_code
	localparam [7:0] LOAD	= 8'b01000000;
	localparam [7:0] STORE	= 8'b01000100;
	localparam [7:0] JAL		= 8'b01001000;
	localparam [7:0] JCOND	= 8'b01001100;
	localparam [7:0] LSH		= 8'b10000100;
	localparam [3:0] LUI		= 4'b1111; 
	localparam [3:0] BCOND	= 4'b1100;
	
	// state register
   always @(posedge clk)
      if(~reset) 
		begin
			previous_state <= NULL;
			state <= FETCH;
		end
      else
		begin 
			previous_state <= state;
			state <= next_state;
		end
	
	
	// Update next_state
	// None of this needs to be changed to add new instructions
	always @(*)
	begin
		// Check last two bits of op code, this is defined in the ISA handout
		// this really only needs to be set in the ALU_EX state but I got an
		// unknown value for is_immediate right at the start of the testbench
		// it was red, I didn't like it.
		is_immediate <= op_code[1:0] != 0;
		case(state)
			// 1st cycle
			FETCH: next_state <= DECODE;
			
			// 2nd cycle
			DECODE: next_state <= ALU_EX;
			
			// 3rd cycle
			ALU_EX: 
			begin
				if (op_code == 4'b1000) next_state <= LSH;
				// For LUI
				else if (op_code == 4'b1111) next_state <= LUI;
				// All of this stuff sets the 4th cycle
				// For all ALU instructions, except for the ones below.
				else if(op_code == 0 || is_immediate) next_state <= ALU;
				
				// For BCOND
				else if (op_code == 4'b1100) next_state <= WRITE;
				
				
				// Otherwise, it will use the ext_op_code
				else next_state <= {op_code, ext_op_code};
			end
			
			// Load is special, takes 6 cycles
			LOAD: next_state <= LOAD2;
		
			// 5th cycle, go to next instruction
			WRITE: next_state <= FETCH;
			
			// After the ALU_EX cycle, this will happen and thus be the 5th cycle	
			default: next_state <= WRITE;
		endcase
	end
	
	
	// Do the stuff for that state
	always @(*)
		begin
			// reset all the signals, this happens every clock cycle
			alu_A_src <= 0;	
			alu_B_src <= 0; 
			reg_write <= 0; 
			write_to_memory <= 0;
			pc_src <= 0;
			reg_write_src <= 0;
			alu_cont <= 0;
			pc_en <= 0;
			loading <= 0;
			storing <= 0;
			instruction_en <= 0;
			
			case (state)
				// 1st cycle
				FETCH:;
				
				// 2nd cycle
				DECODE: instruction_en <= 1'b1;
				
				// 3rd cycle
				ALU_EX:;
				
				// For the regular alu instructions, both non immediate and immediate
				ALU:
				begin
					alu_A_src <= 1'b1;									// Set source for input a into ALU to current register loaded in A
					alu_B_src <= is_immediate;							// Set source for input a into ALU to current register loaded in B if 0 or to immediate
					alu_cont <= {2'b00, is_immediate ? op_code : ext_op_code};				// Set ALU op code
					if((ext_op_code != 4'b1011) && (op_code != 4'b1011))begin
					reg_write <= 1'b1;									// Enable writing to register A
					end
					reg_write_src <= 1'b0;								// Specify where data is coming from, ALU in this case
				end
					
				// start the loading cycle
				LOAD: loading <= 1'b1;
				
				// finish up by writing result to file
				LOAD2:
				begin
					reg_write <= 1'b1;									// Enabling writing to register A
					reg_write_src <= 2'b01;								// Write data that is from memory reg to register A
				end
				
				// Nothin to special here, allow memory to be written to basic_mem
				STORE: 
				begin
					write_to_memory <= 1'b1;							// Enable writing to memory
					storing <= 1'b1;										// mem_address_load_stor won't just be zeros now
				end
				
				// NOW THIS IS WHERE THINGS ARE UNCERTAIN, UNFINISHED, AND UNTESTED
				JAL:
				begin
					reg_write <= 1'b1;									// Also gotta write PC + 1 to reg_write
					reg_write_src <=	2'b10;							// Set source to pc + 1
				end
				
				JCOND:;
				
				LSH:begin
				alu_cont <= {2'b10, op_code};
				alu_A_src <= 1'b1;
				alu_B_src <= 1'b1;
				reg_write <= 1'b1;									// Enable writing to register A
				reg_write_src <= 1'b0;	
				end
				
				
				LUI: begin 
				alu_A_src <= 1'b1;
				alu_B_src <= 1'b1;
				alu_cont <= {6'b111111};
				reg_write <= 1'b1;
				reg_write_src <= 1'b0;
				
				end
				
				// 5th cycle
				// This is where the source for PC is decided and where it is allowed to update next cycle
				WRITE:
				begin
					// For the most part, instructions just typically increment the counter by one, thats why its the default
					case(previous_state)
					
						JAL: pc_src <= 2'b01;							// We're gonna update the program counter by getting the value in register b
						
						JCOND:
						begin
							if (conds[A_index]) pc_src <= 2'b01;	// Check if the right flags are set for the specified condition
							else pc_src <= 2'b10;						// Increment program counter like normal
						end
						ALU_EX:
						begin
							alu_A_src <= 1'b0;
							alu_B_src <= 1'b1;
							alu_cont <= {2'b11, op_code};
							if (conds[A_index]) pc_src <= 2'b00; 	// Check if the right flags are set for the specified condition increment by alu
							else  pc_src <= 2'b10;						//increment normally
						end
						
						default: pc_src <= 2'b10;						// Program counter should just increment
					endcase
					
					// Finally, enable program counter
					pc_en <= 1'b1;
				end
				default:;	// Should never happen.
			endcase
		end
endmodule 