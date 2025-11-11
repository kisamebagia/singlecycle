module brc (
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_rs2_data,
    input  logic        i_br_un,      // 1: unsigned, 0: signed
    output logic        o_br_less,    // rs1 < rs2
    output logic        o_br_equal    // rs1 == rs2
);
    logic slt_less;
    logic sltu_less;
    
    slt_comparator slt_comp (
        .i_a(i_rs1_data),
        .i_b(i_rs2_data),
        .o_less_than(slt_less)
    );
    
    sltu_comparator sltu_comp (
        .i_a(i_rs1_data),
        .i_b(i_rs2_data),
        .o_less_than(sltu_less)
    );
    
    assign o_br_less = i_br_un ? sltu_less : slt_less;
    
    assign o_br_equal = (i_rs1_data == i_rs2_data);
    
endmodule