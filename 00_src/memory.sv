module memory (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,
    input  logic [3:0]  i_bmask,
    input  logic        i_wren,
    output logic [31:0] o_rdata
);
    // 2KB data memory (byte-addressable)
    logic [7:0] mem [0:2047];
    
    // Extract byte address (lower 11 bits)
    logic [10:0] byte_addr;
    assign byte_addr = i_addr[10:0];
    
    // Read (Little-endian)
    assign o_rdata = {
        mem[byte_addr + 3],  // Bits [31:24]
        mem[byte_addr + 2],  // Bits [23:16]
        mem[byte_addr + 1],  // Bits [15:8]
        mem[byte_addr + 0]   // Bits [7:0]
    };
    
    // Write with byte mask (Little-endian)
    always_ff @(posedge i_clk) begin
        if (i_wren) begin
            if (i_bmask[0]) mem[byte_addr + 0] <= i_wdata[7:0];
            if (i_bmask[1]) mem[byte_addr + 1] <= i_wdata[15:8];
            if (i_bmask[2]) mem[byte_addr + 2] <= i_wdata[23:16];
            if (i_bmask[3]) mem[byte_addr + 3] <= i_wdata[31:24];
        end
    end
endmodule
