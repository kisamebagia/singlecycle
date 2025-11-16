module mux4to1_32bit (
    input  logic [31:0] i_data0,
    input  logic [31:0] i_data1,
    input  logic [31:0] i_data2,
    input  logic [31:0] i_data3,
    input  logic [1:0]  i_sel,
    output logic [31:0] o_data
);
    logic [31:0] stage1_out0, stage1_out1;
    mux2to1_32bit mux01 (
        .i_data0(i_data0),
        .i_data1(i_data1),
        .i_sel(i_sel[0]),
        .o_data(stage1_out0)
    );
    
    mux2to1_32bit mux23 (
        .i_data0(i_data2),
        .i_data1(i_data3),
        .i_sel(i_sel[0]),
        .o_data(stage1_out1)
    );
    
    mux2to1_32bit mux_final (
        .i_data0(stage1_out0),
        .i_data1(stage1_out1),
        .i_sel(i_sel[1]),
        .o_data(o_data)
    );
endmodule
