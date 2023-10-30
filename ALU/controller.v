module controller#(parameter WIDTH = 16, ALU_CONT_BITS = 6, OP_BITS = 4)(

	input clk, reset,
	input [OP_BITS - 1 : 0] op_code, ext_op_code, A_index, B_index,
	input [WIDTH - 1 : 0] 	psr_flags,
	
	output reg alu_A_src,	alu_B_src, reg_write, write_to_memory,
	output reg [1 : 0] pc_src, reg_write_src,
	output reg [ALU_CONT_BITS - 1 : 0] 	alu_cont
	);
	
	// Special
	parameter LOAD 	= 4'b0000;
	parameter STOR 	= 4'b0100;
	parameter JAL		= 4'b1000;
	parameter JCOND 	= 4'b1100;
	
	// Conditions
	parameter EQ 		= 4'b0000;
	parameter NE		= 4'b0001;
	parameter GE		= 4'b1101;
	parameter CS		= 4'b0010;
	parameter CC		= 4'b0011;
	parameter HI		= 4'b0100;
	parameter LS		= 4'b0101;
	parameter LO		= 4'b1010;
	parameter HS		= 4'b1011;
	parameter GT		= 4'b0110;
	parameter LE		= 4'b0111;
	parameter FS		= 4'b1000;
	parameter FC		= 4'b1001;
	parameter LT		= 4'b1100;
	parameter UC		= 4'b1110;
	
	// Internal variables
	wire [14:0] conds;
	wire is_alu_non_immediate, is_special, is_shift, is_bcond, is_lui, c_flag, f_flag, l_flag, z_flag, n_flag;
	
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
		
	assign is_alu_non_immediate 	= op_code == 4'b0000;
	assign is_special					= op_code == 4'b0100;
	assign is_shift					= op_code == 4'b1000;
	assign is_bcond 					= op_code == 4'b1100;
	assign is_lui						= op_code == 4'b1111;
	
	always @(*)
		begin
			alu_A_src <= 1'b0;	
			alu_B_src <= 1'b0; 
			reg_write <= 1'b0; 
			write_to_memory <= 1'b0;
			pc_src <= 2'b00;
			reg_write_src <= 2'b00;
			alu_cont <= 6'b000000;
			
			// For all basic ALU operations, no immediates
			if (is_alu_non_immediate)
				begin
					alu_A_src <= 1'b1;						// Set source for input a into ALU to current register loaded in A
					alu_B_src <= 1'b0;						// Set source for input a into ALU to current register loaded in B
					alu_cont <= {2'b00, ext_op_code};	// Set ALU op code
					reg_write <= 1'b1;						// Enable writing to register A
					reg_write_src <= 1'b0;					// Specify where data is coming from, ALU in this case
					pc_src <= 2'b10;							// Program counter should just increment
				end
			
			
			// For load, store, JAL, and JCOND
			else if (is_special)
				begin
					case (op_code)
						LOAD: 
							begin
								reg_write <= 1'b1;			// Enabling writing to register A
								reg_write_src <= 2'b01;		// Write data that is from memory reg to register A
							end
						STOR: 
							begin
								write_to_memory <= 1'b1;	// Enable writing to memory
							end
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
					endcase
				end
				
			else if (is_shift)
				begin
					alu_cont <= {2'b10, op_code};
				end
			
			else if (is_bcond)
				begin
					alu_cont <= {2'b11, op_code};
				end
				
			else if (is_lui)
				begin
					alu_cont <= {2'b11, op_code};
				end
				
			// Any other instruction with an immediate
			else
				begin
					alu_A_src <= 1'b1;
					alu_B_src <= 1'b1;
					alu_cont <= {2'b00, op_code};
					reg_write <= 1'b1;
					reg_write_src <= 2'b00;
				end
		end
endmodule 