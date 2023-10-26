// Authors:
// The m&ms
// The big K
// The Apple Man

module alu_rf #(parameter WIDTH = 16, ALU_CONT_BITS = 5)(
	input			[WIDTH - 1 : 0] 		a, b, 
	input			[ALU_CONT_BITS : 0] 	alu_cont, 
	output reg	[WIDTH - 1 : 0] 		alu_out, 
	output		[WIDTH - 1 : 0] 		psr_flags
	);
	
	reg c_flag, f_flag, l_flag, z_flag, n_flag;
	wire[WIDTH - 1 : 0] sum, diff, diff_unsigned;

	assign psr_flags = {8'b00000000, n_flag, z_flag, f_flag, 2'b00, l_flag, 1'b0, c_flag};
	assign sum = a + b;
	assign diff = a + ~b + 1;
	assign diff_unsigned = a - b;
	
	always@(*)
		case(alu_cont)
			5'b00000: alu_out <= a & b; 	// AND, ANDI
			5'b00001: alu_out <= a | b; 	// OR, ORI
			5'b00010: alu_out <= a ^ b; 	// XOR
			5'b01011,							// ADDU
			5'b00011:							// ADD, ADDI, BCOND
				begin	
					alu_out <= sum;
					if(alu_cont != 5'b00111) // Don't set flags for ADDU
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
			5'b00100:							// SUB, SUBI
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
			5'b00101:						// CMP, CMPI
				begin
					// N flag
					// Assuming both a and b are of the same sign, if a is smaller than b,
					// there will be a negative 
					if(a[15] == b[15]) n_flag <= a < b ? 1 : 0;
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
			5'b00110: alu_out <= b;		// MOV, MOVI
			5'b00111: 						// LSH	
				begin
					if(b[15] == 1) alu_out <= a>>1;
					if(b[15] == 0) alu_out <= a<<b;			
				end
			5'b01000: alu_out <= b<<8;							// LUI
			5'b01001: alu_out <= a;								// JCOND
			5'b01010: alu_out <= a+1;							// JAL
			5'b01011: alu_out <= b;								// LOAD
		endcase
endmodule
