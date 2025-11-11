module adder_32bit (
    input  logic [31:0] i_a,
    input  logic [31:0] i_b,
    input  logic        i_c_in,
    output logic [31:0] o_sum,
    output logic        o_c_out
);
    logic [32:0] carry;
    
    assign carry[0] = i_c_in;
    
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : adder_chain
            full_adder1bit fa (
                .i_a(i_a[i]),
                .i_b(i_b[i]),
                .i_c_in(carry[i]),
                .o_sum(o_sum[i]),
                .o_c_out(carry[i+1])
            );
        end
    endgenerate
    
    assign o_c_out = carry[32];	
	 
endmodule