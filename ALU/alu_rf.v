// Authors:
// The m&ms
// The big K
// The Apple Man

module alu_rf (input[15:0] a, b, input[5:0] alucont, output reg[15:0] result, output[15:0] psr_flags);

	wire signed [15:0] sinB;
	reg C, F, L, Z, N;
	wire[15:0] sum, diff, diffU;

	//assign psr_flags = {8'b00000000, psr_sub[2:1], psr_add[1], 2'b00, psr_sub[0], 1'b0, psr_add[0]};
	assign psr_flags = {8'b00000000,N,Z,F,2'b00,L,1'b0,C};
	assign sum = a+b;
	assign diff = a + ~b + 1;
	assign diffU = a-b;
	assign sinB = b;
	
	always@(*)
		case(alucont[4:0])
			5'b00000: result <= a & b; // AND, ANDI
			5'b00001: result <= a | b; // OR, ORI
			5'b00010: result <= a ^ b; // XOR
			5'b01011,						// ADDU
			5'b00011:						// ADD, ADDI, BCOND
				begin	
					result <= sum;
					if(alucont != 5'b00111) // don't set flags for ADDU
						begin
							if(sum < (a || b)) C <= 1; // C flag
							else C <= 0;
							if((a[15] == 1 && b[15] == 1 && sum[15] == 0) || (a[15] == 0 && b[15] == 0 && sum[15] == 1)) F <= 1; // TADA F FLAG
							else F <= 0;
						end
				end
			5'b00100:						// SUB, SUBI
				begin
<<<<<<< Updated upstream
					result <= diff;
					if(a < b) C <= 1; // C flag
					else C <= 0;
					if((a[15] == 1 && b[15] == 0 && diffU[15] == 0) || (a[15] == 0 && b[15] == 1 && diffU[15] == 1)) F <= 1; // F Flag							
					else F <= 0;

				end
			5'b00101:						// CMP, CMPI
				begin
					if(a[15] == b[15]) N <= a < b ? 1 : 0; // N FLAG
					else if (a[15] == 1) N <= 1;
					else N <= 0;
					if(diff[15] == 1) L<= 1; // L flag
					else L <= 0;
					if(a == b) Z <= 1; // Z flag
					else Z <= 0;
							end
			5'b00110: result <= b;		// MOV, MOVI
			5'b00111: 						// LSH	
				begin
					if(b[15] == 1) result <= a>>1;
					if(b[15] == 0) result <= a<<b;			
				end
			5'b01000: result <= b<<8;							// LUI
			5'b01001: result <= a;								// JCOND
			5'b01010: result <= a+1;							// JAL

			// B note
			// a is displacement
			// b is just where the pc counter is at. 
			// sure.
//			5'b01001: result <= a;
//				begin
//					case(a)
//						4'b0000:
//						4'b0001:
//						4'b1101:
//						4'b0010:
//						4'b0011:
//						4'b0100:
//						4'b0101:
//						4'b1010:
//						4'b1011:
//						4'b0110:
//						4'b0111:
//						4'b1000:
//						4'b1001:
//						4'b1100:
//						4'b1110:
//						4'b1111:
//				end
		endcase
=======
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
				//bcond
				6'b111100: begin
				if(b [7] == 1'b0) alu_out <= a+b;
				else alu_out <= a - (~b + 9'b100000001);
				end
				// LUI
				6'b111111: alu_out <= b<<8;	
				default:alu_out <= 0;
			endcase
		end
>>>>>>> Stashed changes
endmodule
