module single_cycle (
    input  logic        i_clk,
    input  logic        i_reset,
    
    output logic [31:0] o_pc_debug,
    output logic        o_insn_vld,
    
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw
);

    logic [31:0] pc, pc_next, pc_four, pc_imm;
    logic [1:0]  pc_sel;
    logic [31:0] instruction;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] imm;
    logic [2:0]  imm_sel;
    logic [31:0] rs1_data, rs2_data, rd_data;
    logic        reg_wen;
    logic [31:0] alu_operand_a, alu_operand_b, alu_result;
    logic [3:0]  alu_sel;
    logic        a_sel, b_sel;
    logic        br_less, br_equal, br_un;
    logic [31:0] lsu_addr, st_data, ld_data;
    logic        mem_wren;
    logic [2:0]  load_type;
    logic [1:0]  store_type, wb_sel;
    
    assign o_pc_debug = pc;
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr  = instruction[11:7];
    
    // Modules
    pc_register pc_reg (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_pc_next(pc_next), .o_pc(pc)
    );
    
    instruction_memory imem (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_addr(pc), .o_rdata(instruction)
    );
    
    insn_valid_gen insn_valid (
        .i_inst(instruction), .i_reset(i_reset),
        .o_insn_vld(o_insn_vld)
    );
    
    control_unit ctrl (
        .i_inst(instruction),
        .i_br_less(br_less), .i_br_equal(br_equal),
        .o_pc_sel(pc_sel), .o_imm_sel(imm_sel),
        .o_reg_wen(reg_wen), .o_br_un(br_un),
        .o_a_sel(a_sel), .o_b_sel(b_sel),
        .o_alu_sel(alu_sel), .o_mem_wren(mem_wren),
        .o_wb_sel(wb_sel), .o_load_type(load_type),
        .o_store_type(store_type)
    );
    
    imm_gen imm_generator (
        .i_inst(instruction), .i_imm_sel(imm_sel),
        .o_imm(imm)
    );
    
    regfile register_file (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_rs1_addr(rs1_addr), .i_rs2_addr(rs2_addr),
        .o_rs1_data(rs1_data), .o_rs2_data(rs2_data),
        .i_rd_addr(rd_addr), .i_rd_data(rd_data),
        .i_rd_wren(reg_wen)
    );
    
    brc branch_comp (
        .i_rs1_data(rs1_data), .i_rs2_data(rs2_data),
        .i_br_un(br_un), .o_br_less(br_less),
        .o_br_equal(br_equal)
    );
    
    alu_operand_a_mux alu_a_mux (
        .i_rs1_data(rs1_data), .i_pc(pc),
        .i_a_sel(a_sel), .o_operand_a(alu_operand_a)
    );
    
    alu_operand_b_mux alu_b_mux (
        .i_rs2_data(rs2_data), .i_imm(imm),
        .i_b_sel(b_sel), .o_operand_b(alu_operand_b)
    );
    
    alu alu_unit (
        .i_op_a(alu_operand_a), .i_op_b(alu_operand_b),
        .i_alu_op(alu_sel), .o_alu_data(alu_result)
    );
    
    assign lsu_addr = alu_result;
    assign st_data  = rs2_data;
    
    lsu load_store_unit (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_lsu_addr(lsu_addr), .i_st_data(st_data),
        .i_lsu_wren(mem_wren),
        .i_load_type(load_type),
        .i_store_type(store_type), 
        .o_ld_data(ld_data),
        .o_io_ledr(o_io_ledr), .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0), .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2), .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4), .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6), .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd), .i_io_sw(i_io_sw)
    );
    
    pc_plus_4 pc_increment (
        .i_pc(pc), .o_pc_four(pc_four)
    );
    
    pc_plus_imm pc_branch (
        .i_pc(pc), .i_imm(imm), .o_pc_imm(pc_imm)
    );
    
    writeback_mux wb_mux (
        .i_ld_data(ld_data), .i_alu_data(alu_result),
        .i_pc_four(pc_four), .i_wb_sel(wb_sel),
        .o_rd_data(rd_data)
    );
    
    pc_update_mux pc_mux (
        .i_pc_four(pc_four), .i_pc_imm(pc_imm),
        .i_alu_data(alu_result), .i_pc_sel(pc_sel),
        .o_pc_next(pc_next)
    );

endmodule
