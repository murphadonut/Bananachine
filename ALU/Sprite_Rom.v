module rom_async #(
    parameter WIDTH=8,
    parameter DEPTH=256,
    parameter INIT_F=""
    ) (
    input wire [ADDRW-1:0] addr,
    output reg [WIDTH-1:0] data
    );

	 
    localparam ADDRW=$clog2(DEPTH);
    reg [WIDTH-1:0] memory [DEPTH];

    initial begin
        if (INIT_F != 0) begin
            $display("Creating rom_async from init file '%s'.", INIT_F);
            $readmemh(INIT_F, memory);
        end
    end

    always @(*) data = memory[addr];
endmodule
