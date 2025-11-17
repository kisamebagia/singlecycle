module mux2to1_32bit (
    input  logic [31:0] i_data0,
    input  logic [31:0] i_data1,
    input  logic        i_sel,
    output logic [31:0] o_data
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : mux_array
            mux2to1_1bit mux (
                .i_data0(i_data0[i]),
                .i_data1(i_data1[i]),
                .i_sel(i_sel),
                .o_data(o_data[i])
            );
        end
    endgenerate
endmodule
