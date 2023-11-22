module clut_simple #() (

	input 	clk_write, clk_read, we,
	input 	[CIDXW-1:0] cidx_write, cidx_read,colr_in,
	output 	[COLRW-1:0] 	colr_out    
	);
    
	 clut_mem #(COLRW, 2**CIDXW, F_PAL, CIDXW) 
	 clut_mem (
        .clk_write(clk_write),
        .clk_read(clk_read),
        .we(we),
        .addr_write(cidx_write),
        .addr_read(cidx_read),
        .data_in(colr_in),
        .data_out(colr_out)
    );
endmodule