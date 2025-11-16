module sltu_comparator (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic        o_less_than
);
    logic [31:0] diff;
    logic unused_overflow, carry_out;
    
    adder_subtractor_32bit sub (
        .i_a(i_a),
        .i_b(i_b),
        .i_sub(1'b1),           
        .o_result(diff),
        .o_overflow(unused_overflow),
        .o_carry(carry_out)
    );

    assign o_less_than = ~carry_out; 
endmodule