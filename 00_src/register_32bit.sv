module register_32bit (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic        i_en,
    input  logic [31:0] i_d,
    output logic [31:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : dff_array
            dff_en_1bit dff (
                .i_clk(i_clk),
                .i_reset(i_reset),
                .i_en(i_en),
                .i_d(i_d[i]),
                .o_q(o_q[i])
            );
        end
    endgenerate
endmodule
