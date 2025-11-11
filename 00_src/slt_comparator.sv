module slt_comparator (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic        o_less_than
);
    logic [31:0] diff;
    logic borrow;
    logic sign_a, sign_b, sign_diff;
    
    subtractor_32bit sub (
        .i_a(i_a),
        .i_b(i_b),
        .o_diff(diff),
        .o_borrow(borrow)
    );
    
    assign sign_a = i_a[31];
    assign sign_b = i_b[31];
    assign sign_diff = diff[31];
    
    assign o_less_than = (sign_a & ~sign_b) | 
                         (~(sign_a ^ sign_b) & sign_diff);
    
endmodule