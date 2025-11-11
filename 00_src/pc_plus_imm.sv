module pc_plus_imm (
    input  logic [31:0] i_pc,
    input  logic [31:0] i_imm,
    output logic [31:0] o_pc_imm
);
    logic carry_out;
    
    adder_32bit adder (
        .i_a(i_pc),
        .i_b(i_imm),
        .i_c_in(1'b0),
        .o_sum(o_pc_imm),
        .o_c_out(carry_out)
    );
endmodule
