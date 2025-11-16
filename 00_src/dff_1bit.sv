module dff_1bit (
    input  logic i_clk,
    input  logic i_reset,  // Active LOW
    input  logic i_d,
    output logic o_q
);

    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin 
            o_q <= 1'b0;
        end else begin
            o_q <= i_d;
        end
    end
endmodule
