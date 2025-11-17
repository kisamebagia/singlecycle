module regfile (
    input  logic        i_clk,
    input  logic        i_reset,
    
    input  logic [4:0]  i_rs1_addr,
    output logic [31:0] o_rs1_data,
    
    input  logic [4:0]  i_rs2_addr,
    output logic [31:0] o_rs2_data,
    
    input  logic [4:0]  i_rd_addr,
    input  logic [31:0] i_rd_data,
    input  logic        i_rd_wren
);

    // =========================================================================
    // Register File Storage
    // =========================================================================
    logic [31:0] registers [0:31];
    
    // =========================================================================
    // Write Logic
    // =========================================================================
    integer i;
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end else begin
            // x0 is always 0
            registers[0] <= 32'h0;
            
            // Write to x1-x31
            if (i_rd_wren && (i_rd_addr != 5'h0)) begin
                registers[i_rd_addr] <= i_rd_data;
            end
        end
    end
    
    // =========================================================================
    // Read Logic - Using continuous assignment
    // =========================================================================
    // CRITICAL: Use wire for register outputs to break the loop
    logic [31:0] reg_out [0:31];
    
    // Continuous assignment from registers to outputs
    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin : reg_assign
            assign reg_out[j] = registers[j];
        end
    endgenerate
    
    // Now use MUX with the continuous assignment outputs
    mux32to1_32bit rs1_mux (
        .i_data0(reg_out[0]),   .i_data1(reg_out[1]),   .i_data2(reg_out[2]),   .i_data3(reg_out[3]),
        .i_data4(reg_out[4]),   .i_data5(reg_out[5]),   .i_data6(reg_out[6]),   .i_data7(reg_out[7]),
        .i_data8(reg_out[8]),   .i_data9(reg_out[9]),   .i_data10(reg_out[10]), .i_data11(reg_out[11]),
        .i_data12(reg_out[12]), .i_data13(reg_out[13]), .i_data14(reg_out[14]), .i_data15(reg_out[15]),
        .i_data16(reg_out[16]), .i_data17(reg_out[17]), .i_data18(reg_out[18]), .i_data19(reg_out[19]),
        .i_data20(reg_out[20]), .i_data21(reg_out[21]), .i_data22(reg_out[22]), .i_data23(reg_out[23]),
        .i_data24(reg_out[24]), .i_data25(reg_out[25]), .i_data26(reg_out[26]), .i_data27(reg_out[27]),
        .i_data28(reg_out[28]), .i_data29(reg_out[29]), .i_data30(reg_out[30]), .i_data31(reg_out[31]),
        .i_sel(i_rs1_addr),
        .o_data(o_rs1_data)
    );
    
    mux32to1_32bit rs2_mux (
        .i_data0(reg_out[0]),   .i_data1(reg_out[1]),   .i_data2(reg_out[2]),   .i_data3(reg_out[3]),
        .i_data4(reg_out[4]),   .i_data5(reg_out[5]),   .i_data6(reg_out[6]),   .i_data7(reg_out[7]),
        .i_data8(reg_out[8]),   .i_data9(reg_out[9]),   .i_data10(reg_out[10]), .i_data11(reg_out[11]),
        .i_data12(reg_out[12]), .i_data13(reg_out[13]), .i_data14(reg_out[14]), .i_data15(reg_out[15]),
        .i_data16(reg_out[16]), .i_data17(reg_out[17]), .i_data18(reg_out[18]), .i_data19(reg_out[19]),
        .i_data20(reg_out[20]), .i_data21(reg_out[21]), .i_data22(reg_out[22]), .i_data23(reg_out[23]),
        .i_data24(reg_out[24]), .i_data25(reg_out[25]), .i_data26(reg_out[26]), .i_data27(reg_out[27]),
        .i_data28(reg_out[28]), .i_data29(reg_out[29]), .i_data30(reg_out[30]), .i_data31(reg_out[31]),
        .i_sel(i_rs2_addr),
        .o_data(o_rs2_data)
    );

endmodule
