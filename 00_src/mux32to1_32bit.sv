module mux32to1_32bit (
    input  logic [31:0] i_data0,  i_data1,  i_data2,  i_data3,
    input  logic [31:0] i_data4,  i_data5,  i_data6,  i_data7,
    input  logic [31:0] i_data8,  i_data9,  i_data10, i_data11,
    input  logic [31:0] i_data12, i_data13, i_data14, i_data15,
    input  logic [31:0] i_data16, i_data17, i_data18, i_data19,
    input  logic [31:0] i_data20, i_data21, i_data22, i_data23,
    input  logic [31:0] i_data24, i_data25, i_data26, i_data27,
    input  logic [31:0] i_data28, i_data29, i_data30, i_data31,
    input  logic [4:0]  i_sel,
    output logic [31:0] o_data
);
    logic [31:0] stage1_out [0:7];
    logic [31:0] stage2_out [0:1];
    
    mux4to1_32bit mux_0   (.i_data0(i_data0),  .i_data1(i_data1),  .i_data2(i_data2),  .i_data3(i_data3),  .i_sel(i_sel[1:0]), .o_data(stage1_out[0]));
    mux4to1_32bit mux_1   (.i_data0(i_data4),  .i_data1(i_data5),  .i_data2(i_data6),  .i_data3(i_data7),  .i_sel(i_sel[1:0]), .o_data(stage1_out[1]));
    mux4to1_32bit mux_2   (.i_data0(i_data8),  .i_data1(i_data9),  .i_data2(i_data10), .i_data3(i_data11), .i_sel(i_sel[1:0]), .o_data(stage1_out[2]));
    mux4to1_32bit mux_3   (.i_data0(i_data12), .i_data1(i_data13), .i_data2(i_data14), .i_data3(i_data15), .i_sel(i_sel[1:0]), .o_data(stage1_out[3]));
    mux4to1_32bit mux_4   (.i_data0(i_data16), .i_data1(i_data17), .i_data2(i_data18), .i_data3(i_data19), .i_sel(i_sel[1:0]), .o_data(stage1_out[4]));
    mux4to1_32bit mux_5   (.i_data0(i_data20), .i_data1(i_data21), .i_data2(i_data22), .i_data3(i_data23), .i_sel(i_sel[1:0]), .o_data(stage1_out[5]));
    mux4to1_32bit mux_6   (.i_data0(i_data24), .i_data1(i_data25), .i_data2(i_data26), .i_data3(i_data27), .i_sel(i_sel[1:0]), .o_data(stage1_out[6]));
    mux4to1_32bit mux_7   (.i_data0(i_data28), .i_data1(i_data29), .i_data2(i_data30), .i_data3(i_data31), .i_sel(i_sel[1:0]), .o_data(stage1_out[7]));
    
    mux4to1_32bit mux_s2_0 (.i_data0(stage1_out[0]), .i_data1(stage1_out[1]), .i_data2(stage1_out[2]), .i_data3(stage1_out[3]), .i_sel(i_sel[3:2]), .o_data(stage2_out[0]));
    mux4to1_32bit mux_s2_1 (.i_data0(stage1_out[4]), .i_data1(stage1_out[5]), .i_data2(stage1_out[6]), .i_data3(stage1_out[7]), .i_sel(i_sel[3:2]), .o_data(stage2_out[1]));
    
    mux2to1_32bit mux_final (.i_data0(stage2_out[0]), .i_data1(stage2_out[1]), .i_sel(i_sel[4]), .o_data(o_data));
endmodule
