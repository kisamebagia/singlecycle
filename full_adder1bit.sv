module full_adder1bit (
    input  logic i_a,
    input  logic i_b,
    input  logic i_c_in,
    output logic o_sum,
    output logic o_c_out
);
    assign o_sum = i_a ^ i_b ^ i_c_in;
    assign o_c_out = (i_a & i_b) | (i_a & i_c_in) | (i_b & i_c_in);
   endmodule