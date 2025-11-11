module input_buffer (
    input  logic        i_clk,
    input  logic        i_reset,      // Active LOW
    input  logic [31:0] i_io_sw,    
    output logic [31:0] o_sw_data    
);
    logic [31:0] sw_sync1, sw_sync2;
    
    // ? FIX: negedge i_reset, Active LOW
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin
            sw_sync1 <= 32'b0;
            sw_sync2 <= 32'b0;
        end else begin
            sw_sync1 <= i_io_sw;
            sw_sync2 <= sw_sync1;
        end
    end
    
    assign o_sw_data = sw_sync2;
    
endmodule
