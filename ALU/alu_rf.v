// Authors:
// The m&ms
// The big K
// The Apple Man

module alu_rf (input[15:0] a, b, input[5:0] alucont, output reg[15:0] result, output[15:0] psr_flags);

	wire signed [15:0] sinB;
	reg C, F, L, Z, N;
	wire[15:0] sum, diff, diffU;

	assign psr_flags = {8'b00000000, n_flag, z_flag, f_flag, 2'b00, l_flag, 1'b0, c_flag};
	assign sum = a + b;
	assign diff = a + ~b + 1'b1;
	assign diff_unsigned = a - b;
	
	always@(posedge clk)
		if(~reset)
		begin
			c_flag = 0;
			f_flag = 0;
			l_flag = 0;
			z_flag = 0;
			n_flag = 0;
			alu_out = 0;
		end
		else
		begin
			case(alu_cont)
				// AND, 	ANDI
				6'b000001: alu_out <= a & b;
			
				// OR, 	ORI
				6'b000010: alu_out <= a | b;
				
				// XOR,	XORI
				6'b000011: alu_out <= a ^ b; 
			
				// ADDU,	ADDUI
				6'b000110,
				// ADD, 	ADDI
				6'b000101:							
				begin	
					alu_out <= sum;
					if(alu_cont != 6'b000110) // Don't set flags for ADDU and ADDUI
						begin
						
							// C flag
							// There was a carry if the sum becomes somehow smaller than a or b
							if(sum < (a || b)) c_flag <= 1;
							else c_flag <= 0;
							
							// F flag
							// There was an overflow if both a and b were negative and the sum became positive
							// or both a and b were positie and the sum became negative
							if((a[15] == 1 && b[15] == 1 && sum[15] == 0) || (a[15] == 0 && b[15] == 0 && sum[15] == 1)) f_flag <= 1;
							else f_flag <= 0;
						end
				end
				
				// SUB, SUBI
				6'b001001:							
				begin
					alu_out <= diff;
					
					// C flag
					// If a is smaller than b, we'd get a negative, there was a carry
					if(a < b) c_flag <= 1;
					else c_flag <= 0;
					
					// F flag
					// Basically the exact same thing as the add instruction f flag
					if((a[15] == 1 && b[15] == 0 && diff_unsigned[15] == 0) || (a[15] == 0 && b[15] == 1 && diff_unsigned[15] == 1)) f_flag <= 1;							
					else f_flag <= 0;
				end
					
				// CMP, CMPI
				6'b001011:
				begin
					// N flag
					// Assuming both a and b are of the same sign, if a is smaller than b,
					// there will be a negative 
					if(a[15] == b[15]) n_flag <= (a < b ? 1'b1 : 1'b0);
					else if (a[15] == 1) n_flag <= 1;
					else n_flag <= 0;
					
					// L flag
					// Same as N flag but for unsigned a and b
					if(diff[15] == 1) l_flag <= 1;
					else l_flag <= 0;
					
					// Z flag
					// If both a and b are the same, set zero flag
					if(a == b) z_flag <= 1;
					else z_flag <= 0;
				end
				
				// MOV, MOVI
				6'b001101: alu_out <= b;
		
				// LSH
				6'b100101: 							
				begin
					if(b[15] == 1) alu_out <= a>>(~b+1);
					if(b[15] == 0) alu_out <= a<<b;
					else alu_out <= alu_out;
				end
				
				// LSHI
				//6'b100000:
				
								6'b111100: begin
				if(b [7] == 1'b0) alu_out <= a+b;
				else alu_out <= a - (~b + 9'b100000001);
				end


				// LUI
				6'b111111: alu_out <= b<<8;	
				default:alu_out <= 0;
			endcase
		end
endmodule
