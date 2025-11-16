module imm_gen (
    input  logic [31:0] i_inst,      // Instruction
    input  logic [2:0]  i_imm_sel,   // Format select
    output logic [31:0] o_imm        // 32-bit immediate
);

    // ImmSel encoding
    localparam IMM_I = 3'b000;
    localparam IMM_S = 3'b001;
    localparam IMM_B = 3'b010;
    localparam IMM_U = 3'b011;
    localparam IMM_J = 3'b100;
    
    // ========================================
    // Format Builders
    // ========================================
    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    
    // ----------------------------------------
    // I-Format: ADDI, LW, JALR, etc.
    // ----------------------------------------
    // imm[11:0] = inst[31:20]
    // Sign extend to 32 bits
    assign imm_i = {
        {20{i_inst[31]}},  // Sign extend [31:12]
        i_inst[31:20]      // Immediate [11:0]
    };
    
    // ----------------------------------------
    // S-Format: SB, SH, SW
    // ----------------------------------------
    // imm[11:5] = inst[31:25]
    // imm[4:0]  = inst[11:7]
    assign imm_s = {
        {20{i_inst[31]}},  // Sign extend [31:12]
        i_inst[31:25],     // Immediate [11:5]
        i_inst[11:7]       // Immediate [4:0]
    };
    
    // ----------------------------------------
    // B-Format: BEQ, BNE, BLT, BGE, BLTU, BGEU
    // ----------------------------------------
    // imm[12]   = inst[31]
    // imm[11]   = inst[7]
    // imm[10:5] = inst[30:25]
    // imm[4:1]  = inst[11:8]
    // imm[0]    = 0 (implicit, halfword aligned)
    assign imm_b = {
        {19{i_inst[31]}},  // Sign extend [31:13]
        i_inst[31],        // Bit 12
        i_inst[7],         // Bit 11
        i_inst[30:25],     // Bits [10:5]
        i_inst[11:8],      // Bits [4:1]
        1'b0               // Bit 0 (implicit)
    };
    
    // ----------------------------------------
    // U-Format: LUI, AUIPC
    // ----------------------------------------
    // imm[31:12] = inst[31:12]
    // imm[11:0]  = 0
    assign imm_u = {
        i_inst[31:12],     // Upper 20 bits
        12'b0              // Lower 12 bits = 0
    };
    
    // ----------------------------------------
    // J-Format: JAL
    // ----------------------------------------
    // imm[20]    = inst[31]
    // imm[19:12] = inst[19:12]
    // imm[11]    = inst[20]
    // imm[10:1]  = inst[30:21]
    // imm[0]     = 0 (implicit)
    assign imm_j = {
        {11{i_inst[31]}},  // Sign extend [31:21]
        i_inst[31],        // Bit 20
        i_inst[19:12],     // Bits [19:12]
        i_inst[20],        // Bit 11
        i_inst[30:21],     // Bits [10:1]
        1'b0               // Bit 0 (implicit)
    };
    
    // ========================================
    // MUX: Select format based on ImmSel
    // ========================================
    mux8to1_32bit imm_format_mux (
        .i_data0(imm_i),    // 000: I-format
        .i_data1(imm_s),    // 001: S-format
        .i_data2(imm_b),    // 010: B-format
        .i_data3(imm_u),    // 011: U-format
        .i_data4(imm_j),    // 100: J-format
        .i_data5(32'b0),    // 101: Unused
        .i_data6(32'b0),    // 110: Unused
        .i_data7(32'b0),    // 111: Unused
        .i_sel(i_imm_sel),
        .o_data(o_imm)
    );
    
endmodule
