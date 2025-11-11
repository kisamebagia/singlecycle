module lsu (
    input  logic        i_clk,
    input  logic        i_reset,
    
    input  logic [31:0] i_lsu_addr,
    input  logic [31:0] i_st_data,
    input  logic        i_lsu_wren,
    input  logic [2:0]  i_load_type,
    input  logic [1:0]  i_store_type,
    output logic [31:0] o_ld_data,
    
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
    output logic [31:0] o_io_lcd,
    input  logic [31:0] i_io_sw
);
    logic mem_sel, ledr_sel, ledg_sel;
    logic hex0_3_sel, hex4_7_sel, lcd_sel, sw_sel;
    
    logic [31:0] sw_data;
    logic [31:0] mem_rdata;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_bmask;
    logic        mem_wren;
    
    // Address Decoder
    address_decoder addr_dec (
        .i_addr(i_lsu_addr),
        .o_mem_sel(mem_sel),
        .o_ledr_sel(ledr_sel),
        .o_ledg_sel(ledg_sel),
        .o_hex0_3_sel(hex0_3_sel),
        .o_hex4_7_sel(hex4_7_sel),
        .o_lcd_sel(lcd_sel),
        .o_sw_sel(sw_sel)
    );
    
    // Input Buffer (Switches)
    input_buffer in_buf (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_io_sw(i_io_sw),
        .o_sw_data(sw_data)
    );
    
    // Store Data Path
    store_data_path st_path (
        .i_st_data(i_st_data),
        .i_addr_offset(i_lsu_addr[1:0]),
        .i_store_type(i_store_type),
        .o_mem_wdata(mem_wdata),
        .o_byte_mask(mem_bmask)
    );
    
    // Data Memory
    assign mem_wren = i_lsu_wren & mem_sel;
    
    memory data_mem (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_addr(i_lsu_addr),
        .i_wdata(mem_wdata),
        .i_bmask(mem_bmask),
        .i_wren(mem_wren),
        .o_rdata(mem_rdata)
    );
    
    // Output Buffer
    output_buffer out_buf (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_ledr_wren(i_lsu_wren & ledr_sel),
        .i_ledg_wren(i_lsu_wren & ledg_sel),
        .i_hex0_3_wren(i_lsu_wren & hex0_3_sel),
        .i_hex4_7_wren(i_lsu_wren & hex4_7_sel),
        .i_lcd_wren(i_lsu_wren & lcd_sel),
        .i_wdata(mem_wdata),
        .o_io_ledr(o_io_ledr),
        .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0),
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd)
    );
    
    // ? FIX: Priority encoder for read MUX select
    logic [2:0] read_sel;
    
    always_comb begin
        if (sw_sel)
            read_sel = 3'b110;        // i_data6
        else if (lcd_sel)
            read_sel = 3'b101;        // i_data5
        else if (hex4_7_sel)
            read_sel = 3'b100;        // i_data4
        else if (hex0_3_sel)
            read_sel = 3'b011;        // i_data3
        else if (ledg_sel)
            read_sel = 3'b010;        // i_data2
        else if (ledr_sel)
            read_sel = 3'b001;        // i_data1
        else
            read_sel = 3'b000;        // i_data0 (mem_rdata)
    end
    
    // Load Data Path (READ MUX)
    logic [31:0] raw_read_data;
    
    mux8to1_32bit read_mux (
        .i_data0(mem_rdata),
        .i_data1(o_io_ledr),
        .i_data2(o_io_ledg),
        .i_data3({o_io_hex3, 1'b0, o_io_hex2, 1'b0, o_io_hex1, 1'b0, o_io_hex0, 1'b0}),
        .i_data4({o_io_hex7, 1'b0, o_io_hex6, 1'b0, o_io_hex5, 1'b0, o_io_hex4, 1'b0}),
        .i_data5(o_io_lcd),
        .i_data6(sw_data),
        .i_data7(32'b0),
        .i_sel(read_sel),  // ? FIX: Dùng priority encoder
        .o_data(raw_read_data)
    );
    
    // Load data formatting
    load_data_path ld_path (
        .i_mem_data(raw_read_data),
        .i_addr_offset(i_lsu_addr[1:0]),
        .i_load_type(i_load_type),
        .o_load_data(o_ld_data)
    );
    
endmodule
