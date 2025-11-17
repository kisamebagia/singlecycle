module control_unit (
    input  logic [31:0] i_inst,
    input  logic        i_br_less,
    input  logic        i_br_equal,
    
    output logic [2:0]  o_imm_sel,
    output logic        o_reg_wen,
    output logic        o_b_sel,       // 0: rs2, 1: imm
    output logic        o_a_sel,       // 0: rs1, 1: PC
    output logic [3:0]  o_alu_sel,
    output logic        o_mem_wren,
    output logic [1:0]  o_wb_sel,      // 00: alu, 01: mem, 10: pc+4
    output logic [1:0]  o_pc_sel,      // 00: pc+4, 01: pc+imm, 10: alu
    output logic        o_br_un,
    output logic [2:0]  o_load_type,   // Pass funct3 to LSU
    output logic [1:0]  o_store_type,
    output logic        o_insn_vld
);

    // =========================================================================
    // Instruction Decode
    // =========================================================================
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = i_inst[6:0];
    assign funct3 = i_inst[14:12];
    assign funct7 = i_inst[31:25];
    
    // =========================================================================
    // Instruction Type Detection
    // =========================================================================
    logic is_rtype;
    logic is_itype_alu;
    logic is_load;
    logic is_store;
    logic is_branch;
    logic is_jal;
    logic is_jalr;
    logic is_lui;
    logic is_auipc;
    
    assign is_rtype     = (opcode == 7'b0110011);
    assign is_itype_alu = (opcode == 7'b0010011);
    assign is_load      = (opcode == 7'b0000011);
    assign is_store     = (opcode == 7'b0100011);
    assign is_branch    = (opcode == 7'b1100011);
    assign is_jal       = (opcode == 7'b1101111);
    assign is_jalr      = (opcode == 7'b1100111);
    assign is_lui       = (opcode == 7'b0110111);
    assign is_auipc     = (opcode == 7'b0010111);
    
    // =========================================================================
    // Immediate Select
    // =========================================================================
    always_comb begin
        if (is_itype_alu | is_load | is_jalr)
            o_imm_sel = 3'b000;  // I-format
        else if (is_store)
            o_imm_sel = 3'b001;  // S-format
        else if (is_branch)
            o_imm_sel = 3'b010;  // B-format
        else if (is_lui | is_auipc)
            o_imm_sel = 3'b011;  // U-format
        else if (is_jal)
            o_imm_sel = 3'b100;  // J-format
        else
            o_imm_sel = 3'b000;  // Default
    end
    
    // =========================================================================
    // Register Write Enable
    // =========================================================================
    assign o_reg_wen = is_rtype | is_itype_alu | is_load | 
                       is_jal | is_jalr | is_lui | is_auipc;
    
    // =========================================================================
    // ALU Operand Selects
    // =========================================================================
    assign o_b_sel = is_itype_alu | is_load | is_store | is_jalr | is_lui | is_auipc;
    assign o_a_sel = is_jal | is_auipc;
    
    // =========================================================================
    // ALU Operation Select - ENCODING CHU?N
    // =========================================================================
    always_comb begin
        o_alu_sel = 4'b0000;  // Default: ADD
        
        if (is_rtype) begin
            // R-type operations
            case (funct3)
                3'b000: o_alu_sel = (funct7[5] == 1'b1) ? 4'b0001 : 4'b0000;  // SUB : ADD
                3'b001: o_alu_sel = 4'b0010;  // SLL
                3'b010: o_alu_sel = 4'b0011;  // SLT
                3'b011: o_alu_sel = 4'b0100;  // SLTU
                3'b100: o_alu_sel = 4'b0101;  // XOR
                3'b101: o_alu_sel = (funct7[5] == 1'b1) ? 4'b0111 : 4'b0110;  // SRA : SRL
                3'b110: o_alu_sel = 4'b1000;  // OR
                3'b111: o_alu_sel = 4'b1001;  // AND
                default: o_alu_sel = 4'b0000;
            endcase
        end
        else if (is_itype_alu) begin
            // I-type ALU operations
            case (funct3)
                3'b000: o_alu_sel = 4'b0000;  // ADDI
                3'b001: o_alu_sel = 4'b0010;  // SLLI
                3'b010: o_alu_sel = 4'b0011;  // SLTI
                3'b011: o_alu_sel = 4'b0100;  // SLTIU
                3'b100: o_alu_sel = 4'b0101;  // XORI
                3'b101: o_alu_sel = (funct7[5] == 1'b1) ? 4'b0111 : 4'b0110;  // SRAI : SRLI
                3'b110: o_alu_sel = 4'b1000;  // ORI
                3'b111: o_alu_sel = 4'b1001;  // ANDI
                default: o_alu_sel = 4'b0000;
            endcase
        end
        else begin
            o_alu_sel = 4'b0000;  // ADD for LOAD/STORE/JAL/JALR/AUIPC
        end
    end
    
    // =========================================================================
    // Memory Write Enable
    // =========================================================================
    assign o_mem_wren = is_store;
    
    // =========================================================================
    // Write-Back Select
    // =========================================================================
    always_comb begin
        if (is_load)
            o_wb_sel = 2'b01;  // Memory data
        else if (is_jal | is_jalr)
            o_wb_sel = 2'b10;  // PC + 4
        else
            o_wb_sel = 2'b00;  // ALU result
    end
    
    // =========================================================================
    // Branch Logic
    // =========================================================================
    logic branch_taken;
    
    always_comb begin
        branch_taken = 1'b0;
        
        if (is_branch) begin
            case (funct3)
                3'b000: branch_taken = i_br_equal;   // BEQ
                3'b001: branch_taken = ~i_br_equal;  // BNE
                3'b100: branch_taken = i_br_less;    // BLT
                3'b101: branch_taken = ~i_br_less;   // BGE
                3'b110: branch_taken = i_br_less;    // BLTU
                3'b111: branch_taken = ~i_br_less;   // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
    end
    
    // =========================================================================
    // PC Select
    // =========================================================================
    always_comb begin
        if (is_jalr)
            o_pc_sel = 2'b10;  // JALR: use ALU result (rs1 + imm)
        else if (is_jal | (is_branch & branch_taken))
            o_pc_sel = 2'b01;  // JAL or taken branch: PC + imm
        else
            o_pc_sel = 2'b00;  // Normal: PC + 4
    end
    
    // =========================================================================
    // Branch Unsigned
    // =========================================================================
    assign o_br_un = (funct3 == 3'b110) | (funct3 == 3'b111);
    
    // =========================================================================
    // Load/Store Type
    // =========================================================================
    assign o_load_type  = funct3;
    assign o_store_type = funct3[1:0];
    
    // =========================================================================
    // Instruction Valid
    // =========================================================================
    assign o_insn_vld = is_rtype | is_itype_alu | is_load | is_store |
                        is_branch | is_jal | is_jalr | is_lui | is_auipc;

endmodule
