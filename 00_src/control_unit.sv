module control_unit (
    input  logic [31:0] i_inst,
    input  logic        i_br_less,
    input  logic        i_br_equal,
    output logic [1:0]  o_pc_sel,
    output logic [2:0]  o_imm_sel,
    output logic        o_reg_wen,
    output logic        o_br_un,
    output logic        o_a_sel,
    output logic        o_b_sel,
    output logic [3:0]  o_alu_sel,
    output logic        o_mem_wren,
    output logic [1:0]  o_wb_sel,
    output logic [2:0]  o_load_type,
    output logic [1:0]  o_store_type
);
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;
    
    assign opcode = i_inst[6:0];
    assign funct3 = i_inst[14:12];
    assign funct7 = i_inst[31:25];
    
    logic is_rtype, is_itype_alu, is_load, is_store;
    logic is_branch, is_jal, is_jalr, is_lui, is_auipc;
    
    assign is_rtype     = (opcode == 7'b0110011);
    assign is_itype_alu = (opcode == 7'b0010011);
    assign is_load      = (opcode == 7'b0000011);
    assign is_store     = (opcode == 7'b0100011);
    assign is_branch    = (opcode == 7'b1100011);
    assign is_jal       = (opcode == 7'b1101111);
    assign is_jalr      = (opcode == 7'b1100111);
    assign is_lui       = (opcode == 7'b0110111);
    assign is_auipc     = (opcode == 7'b0010111);
    
    logic is_f7_0000000, is_f7_0100000;
    assign is_f7_0000000 = (funct7 == 7'b0000000);
    assign is_f7_0100000 = (funct7 == 7'b0100000);
    
    logic is_sub, is_sra;
    assign is_sub = is_rtype & (funct3 == 3'b000) & is_f7_0100000;
    assign is_sra = (is_rtype | is_itype_alu) & (funct3 == 3'b101) & is_f7_0100000;
    
    // IMM select
    always_comb begin
        if (is_itype_alu | is_load | is_jalr)
            o_imm_sel = 3'b000;
        else if (is_store)
            o_imm_sel = 3'b001;
        else if (is_branch)
            o_imm_sel = 3'b010;
        else if (is_lui | is_auipc)
            o_imm_sel = 3'b011;
        else if (is_jal)
            o_imm_sel = 3'b100;
        else
            o_imm_sel = 3'b000;
    end
    
    assign o_reg_wen = is_rtype | is_itype_alu | is_load | is_jal | is_jalr | is_lui | is_auipc;
    
    assign o_b_sel = is_itype_alu | is_load | is_store | is_jalr | is_jal | is_lui | is_auipc;
    
    assign o_a_sel = is_branch | is_jal | is_auipc;
    
    // ALU operation select
    always_comb begin
        if (is_rtype | is_itype_alu) begin
            case (funct3)
                3'b000: o_alu_sel = is_sub ? 4'b0001 : 4'b0000;
                3'b001: o_alu_sel = 4'b0111;
                3'b010: o_alu_sel = 4'b0010;
                3'b011: o_alu_sel = 4'b0011;
                3'b100: o_alu_sel = 4'b0100;
                3'b101: o_alu_sel = is_sra ? 4'b1001 : 4'b1000;
                3'b110: o_alu_sel = 4'b0101;
                3'b111: o_alu_sel = 4'b0110;
                default: o_alu_sel = 4'b0000;
            endcase
        end else begin
            o_alu_sel = 4'b0000;  // ADD for address calculation
        end
    end
    
    assign o_mem_wren = is_store;
    
    // Writeback select
    always_comb begin
        if (is_load)
            o_wb_sel = 2'b00;
        else if (is_jal | is_jalr)
            o_wb_sel = 2'b10;
        else
            o_wb_sel = 2'b01;
    end
    
    // Branch logic
    logic branch_taken;
    always_comb begin
        case (funct3)
            3'b000: branch_taken = i_br_equal;
            3'b001: branch_taken = ~i_br_equal;
            3'b100: branch_taken = i_br_less;
            3'b101: branch_taken = ~i_br_less;
            3'b110: branch_taken = i_br_less;
            3'b111: branch_taken = ~i_br_less;
            default: branch_taken = 1'b0;
        endcase
    end
    
    // PC select
    always_comb begin
        if (is_jalr)
            o_pc_sel = 2'b10;
        else if (is_jal | (is_branch & branch_taken))
            o_pc_sel = 2'b01;
        else
            o_pc_sel = 2'b00;
    end
    
    assign o_br_un = is_branch & ((funct3 == 3'b110) | (funct3 == 3'b111));
    assign o_load_type = funct3;
    assign o_store_type = funct3[1:0];
    
endmodule
