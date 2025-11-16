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

    // ... (gi? nguyên ph?n khai báo signals)
    
    logic [31:0] pc, pc_next, pc_four, pc_imm;
    logic [1:0]  pc_sel;
    logic [31:0] instr;
    logic [4:0]  rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rs1_data, rs2_data, rd_data;
    logic        rd_wren;
    logic [31:0] imm;
    logic [2:0]  imm_sel;
    logic [31:0] operand_a, operand_b, alu_data;
    logic [3:0]  alu_op;
    logic        a_sel, b_sel;
    logic        br_less, br_equal, br_un;
    logic [31:0] ld_data;
    logic        mem_wren;
    logic [2:0]  load_type;
    logic [1:0]  store_type;
    logic [1:0]  wb_sel;

    // =========================================================================
    // ?? DEBUG MONITOR - CH? IN RA CÁC INSTRUCTION ?ANG TEST
    // =========================================================================
    logic [6:0] opcode_debug;
    logic [2:0] funct3_debug;
    logic [6:0] funct7_debug;
    
    assign opcode_debug = instr[6:0];
    assign funct3_debug = instr[14:12];
    assign funct7_debug = instr[31:25];
    
    // Debug: In ra m?i khi có instruction m?i
    always @(posedge i_clk) begin
        if (!i_reset && o_insn_vld) begin
            // Ch? debug R-type và I-type ALU
            if (opcode_debug == 7'b0110011 || opcode_debug == 7'b0010011) begin
                $display("========================================");
                $display("PC=%h | INSTR=%h", pc, instr);
                $display("Opcode=%b Funct3=%b Funct7=%b", opcode_debug, funct3_debug, funct7_debug);
                $display("RS1[%0d]=%h RS2[%0d]=%h RD[%0d]", rs1_addr, rs1_data, rs2_addr, rs2_data, rd_addr);
                $display("A_SEL=%b B_SEL=%b", a_sel, b_sel);
                $display("OPERAND_A=%h OPERAND_B=%h", operand_a, operand_b);
                $display("ALU_OP=%b ALU_DATA=%h", alu_op, alu_data);
                $display("WB_SEL=%b RD_WREN=%b RD_DATA=%h", wb_sel, rd_wren, rd_data);
                
                // Decode instruction name
                if (opcode_debug == 7'b0110011) begin
                    case (funct3_debug)
                        3'b000: $display(">>> R-Type: %s", (funct7_debug[5]) ? "SUB" : "ADD");
                        3'b001: $display(">>> R-Type: SLL");
                        3'b010: $display(">>> R-Type: SLT");
                        3'b011: $display(">>> R-Type: SLTU");
                        3'b100: $display(">>> R-Type: XOR");
                        3'b101: $display(">>> R-Type: %s", (funct7_debug[5]) ? "SRA" : "SRL");
                        3'b110: $display(">>> R-Type: OR");
                        3'b111: $display(">>> R-Type: AND");
                    endcase
                end else begin
                    case (funct3_debug)
                        3'b000: $display(">>> I-Type: ADDI");
                        3'b001: $display(">>> I-Type: SLLI");
                        3'b010: $display(">>> I-Type: SLTI");
                        3'b011: $display(">>> I-Type: SLTIU");
                        3'b100: $display(">>> I-Type: XORI");
                        3'b101: $display(">>> I-Type: %s", (funct7_debug[5]) ? "SRAI" : "SRLI");
                        3'b110: $display(">>> I-Type: ORI");
                        3'b111: $display(">>> I-Type: ANDI");
                    endcase
                end
                $display("========================================");
            end
        end
    end

    // ... (gi? nguyên ph?n còn l?i - các module instantiations)
    
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

    mux4to1_32bit u_pc_mux (
        .i_data0(pc_four),
        .i_data1(pc_imm),
        .i_data2(alu_data),
        .i_data3(32'b0),
        .i_sel(pc_sel),
        .o_data(pc_next)
    );

    assign o_pc_debug = pc;

    instruction_memory u_imem (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_addr(pc),
        .o_rdata(instr)
    );

    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];

    control_unit u_ctrl (
        .i_inst(instr),
        .i_br_less(br_less),
        .i_br_equal(br_equal),
        .o_imm_sel(imm_sel),
        .o_reg_wen(rd_wren),
        .o_b_sel(b_sel),
        .o_a_sel(a_sel),
        .o_alu_sel(alu_op),
        .o_mem_wren(mem_wren),
        .o_wb_sel(wb_sel),
        .o_pc_sel(pc_sel),
        .o_br_un(br_un),
        .o_load_type(load_type),
        .o_store_type(store_type),
        .o_insn_vld(o_insn_vld)
    );

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

    imm_gen u_immgen (
        .i_inst(instr),
        .i_imm_sel(imm_sel),
        .o_imm(imm)
    );

    brc u_brc (
        .i_rs1_data(rs1_data),
        .i_rs2_data(rs2_data),
        .i_br_un(br_un),
        .o_br_less(br_less),
        .o_br_equal(br_equal)
    );

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

    alu u_alu (
        .i_op_a(operand_a),
        .i_op_b(operand_b),
        .i_alu_op(alu_op),
        .o_alu_data(alu_data)
    );

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

    mux4to1_32bit u_wb_mux (
        .i_data0(alu_data),
        .i_data1(ld_data),
        .i_data2(pc_four),
        .i_data3(32'b0),
        .i_sel(wb_sel),
        .o_data(rd_data)
    );
always @(posedge i_clk) begin
    if (!i_reset && o_insn_vld) begin
        // IN T?T C? INSTRUCTIONS!
        $display("========================================");
        $display("PC=%h | INSTR=%h", pc, instr);
        $display("Opcode=%b Funct3=%b Funct7=%b", opcode_debug, funct3_debug, funct7_debug);
        $display("RS1[%0d]=%h RS2[%0d]=%h RD[%0d]", rs1_addr, rs1_data, rs2_addr, rs2_data, rd_addr);
        $display("ALU_OP=%b | OPERAND_A=%h OPERAND_B=%h", alu_op, operand_a, operand_b);
        $display("ALU_DATA=%h | RD_DATA=%h", alu_data, rd_data);
        $display("========================================");
    end
end

endmodule
