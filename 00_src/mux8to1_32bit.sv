module mux8to1_32bit (
    input  logic [31:0] i_data0, i_data1, i_data2, i_data3,
    input  logic [31:0] i_data4, i_data5, i_data6, i_data7,
    input  logic [2:0]  i_sel,
    output logic [31:0] o_data
);
    logic [31:0] stage1_out0, stage1_out1;
    
    mux4to1_32bit mux_0to3 (
        .i_data0(i_data0), .i_data1(i_data1),
        .i_data2(i_data2), .i_data3(i_data3),
        .i_sel(i_sel[1:0]),
        .o_data(stage1_out0)
    );
    
    mux4to1_32bit mux_4to7 (
        .i_data0(i_data4), .i_data1(i_data5),
        .i_data2(i_data6), .i_data3(i_data7),
        .i_sel(i_sel[1:0]),
        .o_data(stage1_out1)
    );
    
    mux2to1_32bit mux_final (
        .i_data0(stage1_out0),
        .i_data1(stage1_out1),
        .i_sel(i_sel[2]),
        .o_data(o_data)
    );
endmodule
