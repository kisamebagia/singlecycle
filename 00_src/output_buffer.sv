module output_buffer (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic        i_ledr_wren,
    input  logic        i_ledg_wren,
    input  logic        i_hex0_3_wren,
    input  logic        i_hex4_7_wren,
    input  logic        i_lcd_wren,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd
);
    logic [31:0] ledr_reg, ledg_reg;
    logic [31:0] hex0_3_reg, hex4_7_reg;
    logic [31:0] lcd_reg;
   
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            ledr_reg <= 32'b0;
        else if (i_ledr_wren)
            ledr_reg <= i_wdata;
    end
    assign o_io_ledr = ledr_reg;
    
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            ledg_reg <= 32'b0;
        else if (i_ledg_wren)
            ledg_reg <= i_wdata;
    end
    assign o_io_ledg = ledg_reg;
    
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            hex0_3_reg <= 32'b0;
        else if (i_hex0_3_wren)
            hex0_3_reg <= i_wdata;
    end
    assign o_io_hex0 = hex0_3_reg[6:0];
    assign o_io_hex1 = hex0_3_reg[14:8];
    assign o_io_hex2 = hex0_3_reg[22:16];
    assign o_io_hex3 = hex0_3_reg[30:24];
    
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            hex4_7_reg <= 32'b0;
        else if (i_hex4_7_wren)
            hex4_7_reg <= i_wdata;
    end
    assign o_io_hex4 = hex4_7_reg[6:0];
    assign o_io_hex5 = hex4_7_reg[14:8];
    assign o_io_hex6 = hex4_7_reg[22:16];
    assign o_io_hex7 = hex4_7_reg[30:24];
    
    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset)
            lcd_reg <= 32'b0;
        else if (i_lcd_wren)
            lcd_reg <= i_wdata;
    end
    assign o_io_lcd = lcd_reg;
    
endmodule
