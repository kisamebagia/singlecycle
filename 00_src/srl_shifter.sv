module srl_shifter (
    input  logic [31:0] i_data,
    input  logic [4:0]  i_shamt,
    output logic [31:0] o_result
);
    logic [31:0] stage0, stage1, stage2, stage3, stage4;
    logic [31:0] stage0_shifted, stage1_shifted, stage2_shifted, stage3_shifted, stage4_shifted;
    
    // Stage 0: Shift by 1 if shamt[0] = 1
    assign stage0_shifted = {1'b0, i_data[31:1]};
    mux2to1_32bit mux0 (
        .i_data0(i_data),
        .i_data1(stage0_shifted),
        .i_sel(i_shamt[0]),
        .o_data(stage0)
    );
    
    // Stage 1: Shift by 2 if shamt[1] = 1
    assign stage1_shifted = {2'b0, stage0[31:2]};
    mux2to1_32bit mux1 (
        .i_data0(stage0),
        .i_data1(stage1_shifted),
        .i_sel(i_shamt[1]),
        .o_data(stage1)
    );
    
    // Stage 2: Shift by 4 if shamt[2] = 1
    assign stage2_shifted = {4'b0, stage1[31:4]};
    mux2to1_32bit mux2 (
        .i_data0(stage1),
        .i_data1(stage2_shifted),
        .i_sel(i_shamt[2]),
        .o_data(stage2)
    );
    
    // Stage 3: Shift by 8 if shamt[3] = 1
    assign stage3_shifted = {8'b0, stage2[31:8]};
    mux2to1_32bit mux3 (
        .i_data0(stage2),
        .i_data1(stage3_shifted),
        .i_sel(i_shamt[3]),
        .o_data(stage3)
    );
    
    // Stage 4: Shift by 16 if shamt[4] = 1
    assign stage4_shifted = {16'b0, stage3[31:16]};
    mux2to1_32bit mux4 (
        .i_data0(stage3),
        .i_data1(stage4_shifted),
        .i_sel(i_shamt[4]),
        .o_data(stage4)
    );
    
    assign o_result = stage4;
    
endmodule