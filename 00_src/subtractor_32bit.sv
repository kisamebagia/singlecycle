module subtractor_32bit (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic [31:0] o_diff,
    output logic        o_borrow
);
    logic [31:0] b_inverted;
    logic carry_out;
    
    assign b_inverted = ~i_b;
    
    adder_32bit sub_adder (
        .i_a(i_a),
        .i_b(b_inverted),
        .i_c_in(1'b1),
        .o_sum(o_diff),
        .o_c_out(carry_out)
    );
    
    assign o_borrow = ~carry_out;
    
endmodule