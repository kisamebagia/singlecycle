module pc_plus_4 (
    input  logic [31:0] i_pc,
    output logic [31:0] o_pc_four
);
    logic carry_out;
    adder_32bit adder (
        .i_a(i_pc),
        .i_b(32'h0000_0004),
        .i_c_in(1'b0),
        .o_sum(o_pc_four),
        .o_c_out(carry_out)
    );
endmodule
