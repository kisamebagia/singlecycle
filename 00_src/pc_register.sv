module pc_register (
    input  logic        i_clk,
    input  logic        i_reset,      // Active LOW
    input  logic [31:0] i_pc_next,
    output logic [31:0] o_pc
);
    logic [31:0] pc_aligned;
    
    assign pc_aligned = {i_pc_next[31:2], 2'b00};
    
    always_ff @(posedge i_clk) begin
        if (!i_reset)
            o_pc <= 32'h0000_0000;
        else
            o_pc <= pc_aligned;
    end
endmodule
