module adder_subtractor_32bit (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    input  logic        i_sub,      // 0: c?ng, 1: tr?
    output logic [31:0] o_result,
    output logic        o_overflow, // Overflow cho signed
    output logic        o_carry     // Carry-out/Borrow
);
    logic [31:0] b_xor;
    logic [32:0] carry;
    
    // XOR b v?i i_sub: n?u i_sub=1 thì ??o bit (t?o two's complement)
    assign b_xor = i_b ^ {32{i_sub}};
    
    // Carry-in ban ??u = i_sub (cho two's complement khi tr?)
    assign carry[0] = i_sub;
    
    // Chain 32 full adders
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : adder_chain
            full_adder1bit fa (
                .i_a(i_a[i]),
                .i_b(b_xor[i]),
                .i_c_in(carry[i]),
                .o_sum(o_result[i]),
                .o_c_out(carry[i+1])
            );
        end
    endgenerate
    
    // Carry-out cu?i cùng
    assign o_carry = carry[32];
    assign o_overflow = carry[31] ^ carry[32];
    
endmodule