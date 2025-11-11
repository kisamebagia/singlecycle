module alu_operand_b_mux (
    input  logic [31:0] i_rs2_data,
    input  logic [31:0] i_imm,
    input  logic        i_b_sel,
    output logic [31:0] o_operand_b
);
    mux2to1_32bit mux_b (
        .i_data0(i_rs2_data),
        .i_data1(i_imm),
        .i_sel(i_b_sel),
        .o_data(o_operand_b)
    );
endmodule
