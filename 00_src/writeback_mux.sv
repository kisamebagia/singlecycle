module writeback_mux (
    input logic [31:0] i_ld_data,  
    input logic [31:0] i_alu_data,  
    input logic [31:0] i_pc_four,   
    input logic [1:0]  i_wb_sel,    
    output logic [31:0] o_rd_data   
);

    mux4to1_32bit wb_mux (
        .i_data0(i_ld_data),   // sel=00 ? Load data
        .i_data1(i_alu_data),  // sel=01 ? ALU data ? FIX!
        .i_data2(i_pc_four),   // sel=10 ? PC + 4
        .i_data3(32'b0),       // sel=11 ? default
        .i_sel(i_wb_sel),
        .o_data(o_rd_data)
    );

endmodule
