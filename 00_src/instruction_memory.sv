module instruction_memory (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_addr,
    output logic [31:0] o_rdata
);
    logic [31:0] mem [0:2047];  
    
    initial begin
        $readmemh("../02_test/isa_4b.hex", mem);
        $display("[IMEM] Loaded isa_4b.hex - %0d words", 2048);
    end
    
    assign o_rdata = mem[i_addr[12:2]];
endmodule
