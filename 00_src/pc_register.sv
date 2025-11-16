module pc_register (
    input  logic        i_clk,
    input  logic        i_reset,      // Active LOW
    input  logic [31:0] i_pc_next,
    output logic [31:0] o_pc
);
    always_ff @(posedge i_clk) begin
        if (!i_reset)
            o_pc <= 32'h0000_0000;  // Reset to address 0
        else
            o_pc <= i_pc_next;       // Update PC
    end
endmodule
