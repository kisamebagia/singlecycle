module decoder_5to32 (
    input  logic [4:0]  i_addr,
    input  logic        i_enable,
    output logic [31:0] o_select
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : decoder_logic
            localparam logic [4:0] IDX = i[4:0];

            // XNOR implementation: a XNOR b = (a AND b) OR (NOT a AND NOT b)
            logic xnor_bit[4:0];
            logic match;
            
            // Bit-by-bit XNOR comparison
            assign xnor_bit[0] = (i_addr[0] & IDX[0]) | (~i_addr[0] & ~IDX[0]);
            assign xnor_bit[1] = (i_addr[1] & IDX[1]) | (~i_addr[1] & ~IDX[1]);
            assign xnor_bit[2] = (i_addr[2] & IDX[2]) | (~i_addr[2] & ~IDX[2]);
            assign xnor_bit[3] = (i_addr[3] & IDX[3]) | (~i_addr[3] & ~IDX[3]);
            assign xnor_bit[4] = (i_addr[4] & IDX[4]) | (~i_addr[4] & ~IDX[4]);
            
            // Match when all bits are equal (all xnor_bits are 1)
            assign match = xnor_bit[0] & xnor_bit[1] & xnor_bit[2] & xnor_bit[3] & xnor_bit[4];

            assign o_select[i] = match & i_enable;
        end
    endgenerate
endmodule
