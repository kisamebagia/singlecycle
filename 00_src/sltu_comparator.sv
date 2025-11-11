module sltu_comparator (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    output logic        o_less_than
);
    logic [31:0] diff;
    logic borrow;
    
    subtractor_32bit sub (
        .i_a(i_a),
        .i_b(i_b),
        .o_diff(diff),
        .o_borrow(borrow)
    );
    
    assign o_less_than = borrow;
    
endmodule