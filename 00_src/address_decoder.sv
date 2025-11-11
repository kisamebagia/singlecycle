module address_decoder (
    input  logic [31:0] i_addr,
    output logic        o_mem_sel,      // 0x0000_0000 - 0x0000_07FF
    output logic        o_ledr_sel,     // 0x1000_0000 - 0x1000_0FFF
    output logic        o_ledg_sel,     // 0x1000_1000 - 0x1000_1FFF
    output logic        o_hex0_3_sel,   // 0x1000_2000 - 0x1000_2FFF
    output logic        o_hex4_7_sel,   // 0x1000_3000 - 0x1000_3FFF
    output logic        o_lcd_sel,      // 0x1000_4000 - 0x1000_4FFF
    output logic        o_sw_sel        // 0x1001_0000 - 0x1001_0FFF
);
    // Memory: [0x0000_0000, 0x0000_07FF]
    assign o_mem_sel = (i_addr[31:11] == 21'h0000_0) && (i_addr[10:0] <= 11'h7FF);
    
    // Decode high bits [31:12] cho I/O regions
    logic [19:0] addr_high;
    assign addr_high = i_addr[31:12];
    
    assign o_ledr_sel    = (addr_high == 20'h10000);  // 0x1000_0xxx
    assign o_ledg_sel    = (addr_high == 20'h10001);  // 0x1000_1xxx
    assign o_hex0_3_sel  = (addr_high == 20'h10002);  // 0x1000_2xxx
    assign o_hex4_7_sel  = (addr_high == 20'h10003);  // 0x1000_3xxx
    assign o_lcd_sel     = (addr_high == 20'h10004);  // 0x1000_4xxx
    assign o_sw_sel      = (addr_high == 20'h10010);  // 0x1001_0xxx
    
endmodule
