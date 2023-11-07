module controller#(parameter WIDTH = 16, ALU_CONT_BITS = 6, REG_BITS = 4, OP_CODE_BITS = 4, EXT_OP_CODE_BITS = 4)(

	input clk, reset,
	input [OP_CODE_BITS - 1 : 0] op_code, 
	input [EXT_OP_CODE_BITS - 1 : 0] ext_op_code,
	input [REG_BITS - 1: 0] A_index, B_index,
	input [WIDTH - 1 : 0] 	psr_flags,
	
	output reg alu_A_src,	alu_B_src, reg_write, write_to_memory, pc_en, loading, storing,
	output reg [1 : 0] pc_src, reg_write_src, 
	output reg [ALU_CONT_BITS - 1 : 0] 	alu_cont
	);
	
	// Special
	localparam LOAD 	= 4'b0000;
	localparam STOR 	= 4'b0100;
	localparam JAL		= 4'b1000;
	localparam JCOND 	= 4'b1100;
	
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
	
	// General states
	// All these start with a 1, custom states
	localparam FETCH 	= 5'b10001;
	localparam DECODE = 5'b10010;
	localparam LOAD2 	= 5'b10011;
	
	// Internal variables
	wire [14:0] conds;
	wire c_flag, f_flag, l_flag, z_flag, n_flag;
	wire [4:0] is_alu_non_immediate, is_special, is_shift, is_bcond, is_lui;
	// These are just the op_code values with a 0 in the MSB
	assign is_alu_non_immediate 	= 5'b00000;
	assign is_special					= 5'b00100;
	assign is_shift					= 5'b01000;
	assign is_bcond 					= 5'b01100;
	assign is_lui						= 5'b01111;
	
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
		
	//reg pc_write;
	reg [4:0] state, next_state;       // state register and nextstate value
	
	// state register
   always @(posedge clk)
      if(~reset) state <= FETCH;
      else state <= next_state;
	
	
	// Update next_state
	always @(*)
		begin
			case(state)
				FETCH: next_state <= DECODE;
				DECODE: next_state <= {1'b0, op_code};
				is_special:
				begin
					case(ext_op_code)
						LOAD: next_state <= LOAD2;
						default: next_state <= FETCH;
					endcase
				end
				default: next_state <= FETCH;			// might need to change
			endcase
		end
	
	// do the stuff for that state my guy
	always @(*)
		begin
			// reset all the stuffs
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
			
			case (state)
				// 1st cycle
				// just for understanding, nothing goes in these
				FETCH:
				begin
				// this whole cycle just puts a result into q_a, q_b, assumes addr_a and addr_b are already set
				// use address in current addr_a and addr_b then put results into q_a and q_b
				end
				
				// 2nd cycle
				DECODE:
				begin
				// results have been put into q_a and a_b, data_from_mem_pc and data_from_mem_load now have values, instruction reg immediately decodes and outputs its bits
				end
				
				// Really crappy way right now, I know, so far, from all the instructions I've tested
				// Load is the only one that takes 4 cycles
				LOAD2:
				begin
					reg_write <= 1'b1;			// Enabling writing to register A
					reg_write_src <= 2'b01;		// Write data that is from memory reg to register A
					pc_en <= 1'b1;					// We can now go to the next instruction
					pc_src <= 2'b10;				// For the next instruction just increment pc by 1
				end
				
				// TESTED
				is_alu_non_immediate:
					begin
						alu_A_src <= 1'b1;						// Set source for input a into ALU to current register loaded in A
						alu_B_src <= 1'b0;						// Set source for input a into ALU to current register loaded in B
						alu_cont <= {2'b00, ext_op_code};	// Set ALU op code
						reg_write <= 1'b1;						// Enable writing to register A
						reg_write_src <= 1'b0;					// Specify where data is coming from, ALU in this case
						pc_src <= 2'b10;							// Program counter should just increment
					end
					
				// loads and stuff
				is_special:
					begin
						case (ext_op_code)
							// Just need to set loading, again, this is not the best way to be doing this
							LOAD: 
								begin
									loading <= 1'b1;
								end
							// works like a charm
							STOR: 
								begin
									write_to_memory <= 1'b1;	// Enable writing to memory
									storing <= 1'b1;				// mem_address_load_stor won't just be zeros now
									pc_en <= 1'b1;					// ready for next instruction
									pc_src <= 2'b10;				// just increment counter by one, not a jump
								end
							// REST NOT TESTED
							JAL: 
								begin
									pc_src <= 2'b01;				// We're gonna update the program counter by getting the value in register b
									reg_write <= 1'b1;			// Also gotta write PC + 1 to reg_write
									reg_write_src <=	2'b10;	// Set source to pc + 1
								end
							JCOND:
								begin
									if (conds[A_index])			// Check if the right flags are set for the specified condition
										begin
											pc_src <= 2'b01;		// Update program counter using value in register b
										end
									else pc_src <= 2'b10;		// Increment program counter like normal
								end
							default:;
						endcase
					end
				
				// not implememted yet
				is_shift:
					begin
						alu_cont <= {2'b10, op_code};
					end
				is_bcond:
					begin
						alu_cont <= {2'b11, op_code};
					end
				is_lui:
					begin
						alu_cont <= {2'b11, op_code};
					end
				
				// Any other instruction with an immediate
				// This has been tested and works phenomenally
				default:
					begin
						alu_A_src <= 1'b1;				// Get value from register A
						alu_B_src <= 1'b1;				// We gonna use an immediate for input B to alu
						alu_cont <= {2'b00, op_code};	// Run the associated function, but put two zeros in front to differentiate from the special instructions
						reg_write <= 1'b1;				// We are gonna want to write the result so set this to yes	
						reg_write_src <= 2'b00;			// Data will be coming staight from the ALU
						pc_en <= 1'b1;						// Finally, go to next instruction
						pc_src <= 2'b10;					// For that next instruction, just increment pc by one, not a jump.
					end
			endcase
		end
endmodule 