module srl_shifter (
    input  logic [31:0] i_data,
    input  logic [4:0]  i_shamt,
    output logic [31:0] o_result
);
    logic [31:0] stage0, stage1, stage2, stage3, stage4;
    
    assign stage0 = i_shamt[0] ? {1'b0, i_data[31:1]} : i_data;
    assign stage1 = i_shamt[1] ? {2'b0, stage0[31:2]} : stage0;
    assign stage2 = i_shamt[2] ? {4'b0, stage1[31:4]} : stage1;
    assign stage3 = i_shamt[3] ? {8'b0, stage2[31:8]} : stage2;
    assign stage4 = i_shamt[4] ? {16'b0, stage3[31:16]} : stage3;
    
    assign o_result = stage4;
    
endmodule