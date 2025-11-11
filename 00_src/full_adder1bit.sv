module full_adder1bit (
    input  logic i_a,
    input  logic i_b,
    input  logic i_c_in,
    output logic o_sum,
    output logic o_c_out
);
    logic sum_temp;
    logic carry_temp1, carry_temp2;

    assign sum_temp = i_a ^ i_b;
    assign o_sum = sum_temp ^ i_c_in;
    
    assign carry_temp1 = i_a & i_b;
    assign carry_temp2 = i_c_in & sum_temp;
    assign o_c_out = carry_temp1 | carry_temp2;
    
endmodule