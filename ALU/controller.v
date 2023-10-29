module controller#(parameter WIDTH = 16, ALU_CONT_BITS = 6, OP_BITS = 4)(

	input clk, reset,
	input [OP_BITS - 1 : 0] op_code, ext_op_code,
	input [WIDTH - 1 : 0] 	psr_flags,
	
	output alu_A_src,	alu_B_src, reg_write, write_to_memory,
	output [1 : 0] pc_src, reg_write_src,
	output [ALU_CONT_BITS - 1 : 0] 	alu_cont
	);
	
	parameter LOAD = 	4'b0000;
	parameter STOR = 	4'b0100;
	parameter JAL 	=	4'b1000;
	parameter JCOND = 4'b1100;
	
	reg is_alu_non_immediate, is_special, is_shift, is_bcond;
		
	assign is_alu_non_immediate 	= op_code == 4'b0000;
	assign is_special					= op_code == 4'b0100;
	assign is_shift					= op_code == 4'b1000;
	assign is_bcond 					= op_code == 4'b1100;
	assign is_lui						= op_code == 4'b1111;

	always @(*)
		begin
			
			// For all basic ALU operations, no immediates
			if (is_alu_non_immediate)
				begin
					alu_A_src <= 1'b1;						// Set source for input a into ALU to current register loaded in A
					alu_B_src <= 1'b0;						// Set source for input a into ALU to current register loaded in B
					alu_cont <= {'2b00, ext_op_code};	// Set ALU op code
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
								reg_write <= 1'b1;
								reg_write_src <= 2'b01;
							end
						STOR: 
							begin
								write_to_memory <= 1'b1;
							end
						JAL: 
							begin
								pc_src <= 2'b01;				// We're gonna update the program counter by getting the value in register a
								reg_write <= 1'b1;			// Also gotta write PC + 1 to reg_write
								reg_write_src <=	2'b10		// Set source to pc + a
							end
						JCOND:
							begin
								
							end
					endcase
					alu_A_src <= 1'b1;
					alu_B_src <= 2'b01;
				end
				
			else if (is_shift)
				begin
					alu_cont <= {2'b10, op_code};
				end
			end
			
			else if (is_bcond)
				begin
					alu_cont <= {2'b11, op_code};
				end
				
			else if (is_lui)
				begin
					alu_cont <= {2'b11, op_code};
				end
				
			else
				begin
					alu_A_src <= 1'b1;
					alu_B_src <= 2'b01;
					alu_cont <= {2'b00, op_code};
				end
		end
endmodule 