module insn_valid_gen (
    input  logic [31:0] i_inst,
    input  logic        i_reset,      
    output logic        o_insn_vld
);
    logic [6:0] opcode;
    assign opcode = i_inst[6:0];
    
    logic is_rtype, is_itype_alu, is_load, is_store;
    logic is_branch, is_jal, is_jalr, is_lui, is_auipc;
    
    assign is_rtype     = (opcode == 7'b0110011);  // R-type
    assign is_itype_alu = (opcode == 7'b0010011);  // I-type ALU
    assign is_load      = (opcode == 7'b0000011);  // Load
    assign is_store     = (opcode == 7'b0100011);  // Store
    assign is_branch    = (opcode == 7'b1100011);  // Branch
    assign is_jal       = (opcode == 7'b1101111);  // JAL
    assign is_jalr      = (opcode == 7'b1100111);  // JALR
    assign is_lui       = (opcode == 7'b0110111);  // LUI
    assign is_auipc     = (opcode == 7'b0010111);  // AUIPC
    
    logic valid_opcode;
    assign valid_opcode = is_rtype | is_itype_alu | is_load | is_store |
                          is_branch | is_jal | is_jalr | is_lui | is_auipc;
    
    assign o_insn_vld = i_reset & valid_opcode;
    
endmodule
