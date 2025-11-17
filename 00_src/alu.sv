module alu (
    input  logic [31:0] i_op_a,
    input  logic [31:0] i_op_b,
    input  logic [3:0]  i_alu_op,
    output logic [31:0] o_alu_data
);
    // ALU operation codes
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;
    
    // Internal signals for each operation result
    logic [31:0] addsub_result;
    logic        slt_result;
    logic        sltu_result;
    logic [31:0] xor_result;
    logic [31:0] or_result;
    logic [31:0] and_result;
    logic [31:0] sll_result;
    logic [31:0] srl_result;
    logic [31:0] sra_result;
    
    // Intermediate signals
    logic [31:0] slt_extended;
    logic [31:0] sltu_extended;
    logic        unused_overflow, unused_carry;
    logic        is_sub;
    
    // =========================================================================
    // Determine if operation is subtraction
    // =========================================================================
    assign is_sub = (i_alu_op == ALU_SUB) | (i_alu_op == ALU_SLT) | (i_alu_op == ALU_SLTU);
    
    // =========================================================================
    // ADD/SUB Operation - Single unified instance
    // =========================================================================
    adder_subtractor_32bit addsub_unit (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .i_sub(is_sub),         // Dynamic control
        .o_result(addsub_result),
        .o_overflow(unused_overflow),
        .o_carry(unused_carry)
    );
    
    // =========================================================================
    // SLT Operation - Signed comparison
    // =========================================================================
    slt_comparator slt_comp (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .o_less_than(slt_result)
    );
    
    assign slt_extended = {31'b0, slt_result};
    
    // =========================================================================
    // SLTU Operation - Unsigned comparison
    // =========================================================================
    sltu_comparator sltu_comp (
        .i_a(i_op_a),
        .i_b(i_op_b),
        .o_less_than(sltu_result)
    );
    
    assign sltu_extended = {31'b0, sltu_result};
    
    // =========================================================================
    // XOR Operation - Bitwise XOR using gates
    // =========================================================================
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : xor_gen
            assign xor_result[i] = (i_op_a[i] & ~i_op_b[i]) | (~i_op_a[i] & i_op_b[i]);
        end
    endgenerate
    
    // =========================================================================
    // OR Operation - Bitwise OR
    // =========================================================================
    assign or_result = i_op_a | i_op_b;
    
    // =========================================================================
    // AND Operation - Bitwise AND
    // =========================================================================
    assign and_result = i_op_a & i_op_b;
    
    // =========================================================================
    // SLL Operation - Shift Left Logical
    // =========================================================================
    sll_shifter sll_unit (
        .i_data(i_op_a),
        .i_shamt(i_op_b[4:0]),
        .o_result(sll_result)
    );
    
    // =========================================================================
    // SRL Operation - Shift Right Logical
    // =========================================================================
    srl_shifter srl_unit (
        .i_data(i_op_a),
        .i_shamt(i_op_b[4:0]),
        .o_result(srl_result)
    );
    
    // =========================================================================
    // SRA Operation - Shift Right Arithmetic
    // =========================================================================
    sra_shifter sra_unit (
        .i_data(i_op_a),
        .i_shamt(i_op_b[4:0]),
        .o_result(sra_result)
    );
    
    // =========================================================================
    // Output MUX - Select result based on operation
    // =========================================================================
    always_comb begin
        case (i_alu_op)
            ALU_ADD:  o_alu_data = addsub_result;  // ADD uses same module
            ALU_SUB:  o_alu_data = addsub_result;  // SUB uses same module
            ALU_SLT:  o_alu_data = slt_extended;
            ALU_SLTU: o_alu_data = sltu_extended;
            ALU_XOR:  o_alu_data = xor_result;
            ALU_OR:   o_alu_data = or_result;
            ALU_AND:  o_alu_data = and_result;
            ALU_SLL:  o_alu_data = sll_result;
            ALU_SRL:  o_alu_data = srl_result;
            ALU_SRA:  o_alu_data = sra_result;
            default:  o_alu_data = 32'b0;
        endcase
    end
    
endmodule
