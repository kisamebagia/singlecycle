module dff_en_1bit (
    input  logic i_clk,
    input  logic i_reset,  
    input  logic i_en,
    input  logic i_d,
    output logic o_q
);
    logic q_reg;  
    logic d_mux; 
    
    // MUX: select i_d when i_en=1, otherwise keep q_reg
    mux2to1_1bit en_mux (
        .i_data0(q_reg),
        .i_data1(i_d),
        .i_sel(i_en),
        .o_data(d_mux)
    );
    
    dff_1bit dff (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_d(d_mux),
        .o_q(q_reg)       
    );
    
    assign o_q = q_reg;
    
endmodule
