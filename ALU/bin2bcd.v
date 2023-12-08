module bin2bcd(
	input [17:0] bin,  // binary
   output reg [23:0] bcd
	); // bcd {...,thousands,hundreds,tens,ones}

  integer j;

	always @(bin) begin
		bcd = 0;
		for(j = 0; j <=17; j = j+1) begin
			if(bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
			if(bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
			if(bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
			if(bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
			if(bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
			if(bcd[23:20] >= 5) bcd[23:20] = bcd[23:20] + 3;
			bcd = {bcd[22:0], bin[17-j]};
		end
	end
endmodule