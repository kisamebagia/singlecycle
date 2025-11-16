module mux2to1_1bit (
    input  logic i_data0,
    input  logic i_data1,
    input  logic i_sel,
    output logic o_data
);
    logic sel_n, and0, and1;
    
    assign sel_n = ~i_sel;
    assign and0 = sel_n & i_data0;
    assign and1 = i_sel & i_data1;
    assign o_data = and0 | and1;
endmodule
