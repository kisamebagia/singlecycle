module dff_en_1bit (
    input  logic i_clk,
    input  logic i_reset,  
    input  logic i_en,
    input  logic i_d,
    output logic o_q
);
    logic q_reg;  
    logic d_mux; 
    
    assign d_mux = i_en ? i_d : q_reg;
    
    dff_1bit dff (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_d(d_mux),
        .o_q(q_reg)       
    );
    
    assign o_q = q_reg;
    
endmodule
