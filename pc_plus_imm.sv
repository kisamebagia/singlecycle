module pc_plus_imm (
    input  logic [31:0] i_pc,
    input  logic [31:0] i_imm,
    output logic [31:0] o_pc_imm
);
    logic unused_overflow, unused_carry;
    
    adder_subtractor_32bit adder (
        .i_a(i_pc),
        .i_b(i_imm),
        .i_sub(1'b0),  // Addition mode
        .o_result(o_pc_imm),
        .o_overflow(unused_overflow),
        .o_carry(unused_carry)
    );
endmodule
