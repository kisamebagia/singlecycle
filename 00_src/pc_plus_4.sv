module pc_plus_4 (
    input  logic [31:0] i_pc,
    output logic [31:0] o_pc_four
);
    logic unused_overflow, unused_carry;
    
    adder_subtractor_32bit adder (
        .i_a(i_pc),
        .i_b(32'h0000_0004),
        .i_sub(1'b0),  // Addition mode
        .o_result(o_pc_four),
        .o_overflow(unused_overflow),
        .o_carry(unused_carry)
    );
endmodule
