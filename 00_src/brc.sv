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
    
    // MUX to select signed or unsigned comparison
    mux2to1_1bit br_less_mux (
        .i_data0(slt_less),
        .i_data1(sltu_less),
        .i_sel(i_br_un),
        .o_data(o_br_less)
    );
    
    // Equality check using XOR
    logic [31:0] xor_result;
    logic or_result;
    
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : eq_check
            logic not_a, not_b, and0, and1;
            assign not_a = ~i_rs1_data[i];
            assign not_b = ~i_rs2_data[i];
            assign and0 = i_rs1_data[i] & not_b;
            assign and1 = not_a & i_rs2_data[i];
            assign xor_result[i] = and0 | and1;
        end
    endgenerate
    
    // OR all bits together
    assign or_result = xor_result[0]  | xor_result[1]  | xor_result[2]  | xor_result[3]  |
                       xor_result[4]  | xor_result[5]  | xor_result[6]  | xor_result[7]  |
                       xor_result[8]  | xor_result[9]  | xor_result[10] | xor_result[11] |
                       xor_result[12] | xor_result[13] | xor_result[14] | xor_result[15] |
                       xor_result[16] | xor_result[17] | xor_result[18] | xor_result[19] |
                       xor_result[20] | xor_result[21] | xor_result[22] | xor_result[23] |
                       xor_result[24] | xor_result[25] | xor_result[26] | xor_result[27] |
                       xor_result[28] | xor_result[29] | xor_result[30] | xor_result[31];
    
    // Equal when XOR result is all zeros (or_result = 0)
    assign o_br_equal = ~or_result;
    
endmodule