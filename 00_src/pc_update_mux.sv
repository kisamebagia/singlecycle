module pc_update_mux (
    input  logic [31:0] i_pc_four,
    input  logic [31:0] i_pc_imm,
    input  logic [31:0] i_alu_data,
    input  logic [1:0]  i_pc_sel,
    output logic [31:0] o_pc_next
);
    logic [31:0] jalr_target;
    
    assign jalr_target = i_alu_data & 32'hFFFFFFFE;
    
    mux4to1_32bit pc_mux (
        .i_data0(i_pc_four),
        .i_data1(i_pc_imm),
        .i_data2(jalr_target), 
        .i_data3(32'b0),
        .i_sel(i_pc_sel),
        .o_data(o_pc_next)
    );
endmodule
