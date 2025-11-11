module regfile (
    input  logic        i_clk,
    input  logic        i_reset,
    
    input  logic [4:0]  i_rs1_addr,
    output logic [31:0] o_rs1_data,
    
    input  logic [4:0]  i_rs2_addr,
    output logic [31:0] o_rs2_data,
    
    input  logic [4:0]  i_rd_addr,
    input  logic [31:0] i_rd_data,
    input  logic        i_rd_wren
);
    // Register file: x0-x31
    logic [31:0] registers [0:31];
    
    // Write logic
    integer i;
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end else begin
            // Only write to x1-x31 (x0 is hardwired to 0)
            if (i_rd_wren && (i_rd_addr != 5'h0)) begin
                registers[i_rd_addr] <= i_rd_data;
            end
        end
    end
    
    // ? FIX: Read logic - x0 always returns 0
    assign o_rs1_data = (i_rs1_addr == 5'h0) ? 32'h0 : registers[i_rs1_addr];
    assign o_rs2_data = (i_rs2_addr == 5'h0) ? 32'h0 : registers[i_rs2_addr];
    
endmodule
