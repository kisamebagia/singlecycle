module alu (
    input  logic [31:0] i_op_a,
    input  logic [31:0] i_op_b,
    input  logic [3:0]  i_alu_op,
    output logic [31:0] o_alu_data
);
 
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLT  = 4'b0010;
    localparam ALU_SLTU = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_OR   = 4'b0101;
    localparam ALU_AND  = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;
    

    logic [31:0] add_result;
    logic [31:0] sub_result;
    logic        slt_result;
    logic        sltu_result;
    logic [31:0] sll_result;
    logic [31:0] srl_result;
    logic [31:0] sra_result;
    
    logic add_carry, sub_borrow;
    
 
    adder_32bit adder (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .i_c_in(1'b0),
        .o_sum(add_result),
        .o_c_out(add_carry)
    );
    
    subtractor_32bit subtractor (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .o_diff(sub_result),
        .o_borrow(sub_borrow)
    );
    
    slt_comparator slt_comp (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .o_less_than(slt_result)
    );
    
    sltu_comparator sltu_comp (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .o_less_than(sltu_result)
    );
    
    sll_shifter sll_shift (
        .i_data(i_op_a),
        .i_shamt(i_op_b[4:0]),
        .o_result(sll_result)
    );
    
    srl_shifter srl_shift (
        .i_data(i_op_a),
        .i_shamt(i_op_b[4:0]),
        .o_result(srl_result)
    );
    
    sra_shifter sra_shift (
        .i_data(i_op_a),
        .i_shamt(i_op_b[4:0]),
        .o_result(sra_result)
    );
    

    always_comb begin
        case (i_alu_op)
            ALU_ADD:  o_alu_data = add_result;
            ALU_SUB:  o_alu_data = sub_result;
            ALU_SLT:  o_alu_data = {31'b0, slt_result};
            ALU_SLTU: o_alu_data = {31'b0, sltu_result};
            ALU_XOR:  o_alu_data = i_op_a ^ i_op_b;
            ALU_OR:   o_alu_data = i_op_a | i_op_b;
            ALU_AND:  o_alu_data = i_op_a & i_op_b;
            ALU_SLL:  o_alu_data = sll_result;
            ALU_SRL:  o_alu_data = srl_result;
            ALU_SRA:  o_alu_data = sra_result;
            default:  o_alu_data = 32'b0;
        endcase
    end
    
endmodule