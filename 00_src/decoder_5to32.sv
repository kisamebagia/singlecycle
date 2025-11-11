module decoder_5to32 (
    input  logic [4:0]  i_addr,
    input  logic        i_enable,
    output logic [31:0] o_select
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : decoder_logic
            localparam logic [4:0] IDX = i;

            wire [4:0] bit_match;
            assign bit_match = i_addr ^~ IDX;    
            wire match;
            assign match = &bit_match;           

            assign o_select[i] = match & i_enable;
        end
    endgenerate
endmodule

