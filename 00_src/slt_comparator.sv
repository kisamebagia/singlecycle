module slt_comparator (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic        o_less_than
);
    logic [31:0] diff;
    logic unused_overflow, borrow;
    logic sign_a, sign_b, sign_diff;
    logic sign_xor, sign_xnor;
    logic cond1, cond2;
    
    // Dùng adder_subtractor thay vì subtractor
    adder_subtractor_32bit sub (
        .i_a(i_a),
        .i_b(i_b),
        .i_sub(1'b1),          
        .o_result(diff),
        .o_overflow(unused_overflow),
        .o_carry(borrow)
    );
    
    assign sign_a = i_a[31];
    assign sign_b = i_b[31];
    assign sign_diff = diff[31];
    
    assign sign_xor = (sign_a & ~sign_b) | (~sign_a & sign_b);
    assign sign_xnor = ~sign_xor;
    
    assign cond1 = sign_a & ~sign_b;
    assign cond2 = sign_xnor & sign_diff;
    
    assign o_less_than = cond1 | cond2;
endmodule