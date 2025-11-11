module sll_shifter (
    input  logic [31:0] i_data,
    input  logic [4:0]  i_shamt,
    output logic [31:0] o_result
);
    logic [31:0] stage0, stage1, stage2, stage3, stage4;
    
    assign stage0 = i_shamt[0] ? {i_data[30:0], 1'b0} : i_data;
    
    assign stage1 = i_shamt[1] ? {stage0[29:0], 2'b0} : stage0;
    
    assign stage2 = i_shamt[2] ? {stage1[27:0], 4'b0} : stage1;
    
    assign stage3 = i_shamt[3] ? {stage2[23:0], 8'b0} : stage2;
    
    assign stage4 = i_shamt[4] ? {stage3[15:0], 16'b0} : stage3;
    
    assign o_result = stage4;
    
endmodule
