module alu_operand_a_mux (
    input  logic [31:0] i_rs1_data,
    input  logic [31:0] i_pc,
    input  logic        i_a_sel,
    output logic [31:0] o_operand_a
);
    mux2to1_32bit mux_a (
        .i_data0(i_rs1_data),
        .i_data1(i_pc),
        .i_sel(i_a_sel),
        .o_data(o_operand_a)
    );
endmodule
