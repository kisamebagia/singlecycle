module single_cycle (
    input  logic        i_clk,
    input  logic        i_reset,

    output logic [31:0] o_pc_debug,
    output logic        o_insn_vld,

    input  logic [31:0] i_io_sw,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,
    output logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,
    output logic [31:0] o_io_lcd
);

    // =========================================================================
    // Signal Declarations
    // =========================================================================
    
    // PC signals
    logic [31:0] pc, pc_next, pc_four, pc_imm;
    logic [1:0]  pc_sel;

    // Instruction
    logic [31:0] instr;

    // Register file
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rs1_data, rs2_data, rd_data;
    logic        rd_wren;

    // Immediate
    logic [31:0] imm;
    logic [2:0]  imm_sel;

    // ALU
    logic [31:0] operand_a, operand_b, alu_data;
    logic [3:0]  alu_op;
    logic        a_sel, b_sel;

    // BRC
    logic        br_less, br_equal, br_un;

    // LSU
    logic [31:0] ld_data;
    logic        mem_wren;
    logic [2:0]  load_type;
    logic [1:0]  store_type;

    // Writeback
    logic [1:0]  wb_sel;

    // =========================================================================
    // PC Logic
    // =========================================================================
    pc_register u_pc_reg (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_pc_next(pc_next),
        .o_pc(pc)
    );

    pc_plus_4 u_pc_plus4 (
        .i_pc(pc),
        .o_pc_four(pc_four)
    );

    pc_plus_imm u_pc_plus_imm (
        .i_pc(pc),
        .i_imm(imm),
        .o_pc_imm(pc_imm)
    );

    // PC MUX: 00=pc+4, 01=pc+imm, 10=alu (JALR)
    mux4to1_32bit u_pc_mux (
        .i_data0(pc_four),
        .i_data1(pc_imm),
        .i_data2(alu_data),
        .i_data3(32'b0),
        .i_sel(pc_sel),
        .o_data(pc_next)
    );

    assign o_pc_debug = pc;

    // =========================================================================
    // Instruction Memory
    // =========================================================================
    instruction_memory u_imem (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_addr(pc),
        .o_rdata(instr)
    );

    // =========================================================================
    // Decode
    // =========================================================================
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];

    // =========================================================================
    // Control Unit - DÙNG CONTROLUNIT.SV M?U
    // =========================================================================
    control_unit u_ctrl (
    .i_inst(instr),              // ? Toàn b? instruction
    .i_br_less(br_less),
    .i_br_equal(br_equal),
    .o_imm_sel(imm_sel),         // ? Tên khác
    .o_reg_wen(rd_wren),         // ? Tên khác
    .o_b_sel(b_sel),             // ? Tên khác
    .o_a_sel(a_sel),             // ? Tên khác
    .o_alu_sel(alu_op),          // ? Tên khác
    .o_mem_wren(mem_wren),
    .o_wb_sel(wb_sel),
    .o_pc_sel(pc_sel),
    .o_br_un(br_un),
    .o_load_type(load_type),     // ? Tên khác
    .o_store_type(store_type),
    .o_insn_vld(o_insn_vld)
);

    // =========================================================================
    // Register File
    // =========================================================================
    regfile u_regfile (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rs1_addr(rs1_addr),
        .o_rs1_data(rs1_data),
        .i_rs2_addr(rs2_addr),
        .o_rs2_data(rs2_data),
        .i_rd_addr(rd_addr),
        .i_rd_data(rd_data),
        .i_rd_wren(rd_wren)
    );

    // =========================================================================
    // Immediate Generator
    // =========================================================================
    imm_gen u_immgen (
        .i_inst(instr),
        .i_imm_sel(imm_sel),
        .o_imm(imm)
    );

    // =========================================================================
    // Branch Comparison
    // =========================================================================
    brc u_brc (
        .i_rs1_data(rs1_data),
        .i_rs2_data(rs2_data),
        .i_br_un(br_un),
        .o_br_less(br_less),
        .o_br_equal(br_equal)
    );

    // =========================================================================
    // ALU Operand MUX
    // =========================================================================
    mux2to1_32bit u_mux_a (
        .i_data0(rs1_data),
        .i_data1(pc),
        .i_sel(a_sel),
        .o_data(operand_a)
    );

    mux2to1_32bit u_mux_b (
        .i_data0(rs2_data),
        .i_data1(imm),
        .i_sel(b_sel),
        .o_data(operand_b)
    );

    // =========================================================================
    // ALU
    // =========================================================================
    alu u_alu (
        .i_op_a(operand_a),
        .i_op_b(operand_b),
        .i_alu_op(alu_op),
        .o_alu_data(alu_data)
    );

    // =========================================================================
    // Load-Store Unit
    // =========================================================================
    lsu u_lsu (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_lsu_addr(alu_data),
        .i_st_data(rs2_data),
        .i_lsu_wren(mem_wren),
        .i_func3(load_type),
        .i_io_sw(i_io_sw),
        .o_io_hex0(o_io_hex0),
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_ld_data(ld_data),
        .o_io_ledr(o_io_ledr),
        .o_io_ledg(o_io_ledg),
        .o_io_lcd(o_io_lcd)
    );

    // =========================================================================
    // Writeback MUX
    // =========================================================================
    mux4to1_32bit u_wb_mux (
        .i_data0(alu_data),
        .i_data1(ld_data),
        .i_data2(pc_four),
        .i_data3(32'b0),
        .i_sel(wb_sel),
        .o_data(rd_data)
    );

endmodule
