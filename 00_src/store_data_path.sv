module store_data_path (
    input  logic [31:0] i_st_data,
    input  logic [1:0]  i_addr_offset,
    input  logic [1:0]  i_store_type,
    output logic [31:0] o_mem_wdata,
    output logic [3:0]  o_byte_mask
);
    localparam [1:0] STORE_BYTE = 2'b00;
    localparam [1:0] STORE_HALF = 2'b01;
    localparam [1:0] STORE_WORD = 2'b10;
    
    logic [31:0] sb_data [0:3];
    logic [3:0]  sb_mask [0:3];
    
    assign sb_data[0] = {24'b0, i_st_data[7:0]};
    assign sb_data[1] = {16'b0, i_st_data[7:0], 8'b0};
    assign sb_data[2] = {8'b0, i_st_data[7:0], 16'b0};
    assign sb_data[3] = {i_st_data[7:0], 24'b0};
    
    assign sb_mask[0] = 4'b0001;
    assign sb_mask[1] = 4'b0010;
    assign sb_mask[2] = 4'b0100;
    assign sb_mask[3] = 4'b1000;
    
    logic [31:0] sb_selected_data;
    logic [3:0]  sb_selected_mask;
    logic [31:0] sb_mask_mux_out; 
    
    mux4to1_32bit sb_data_mux (
        .i_data0(sb_data[0]), .i_data1(sb_data[1]),
        .i_data2(sb_data[2]), .i_data3(sb_data[3]),
        .i_sel(i_addr_offset),
        .o_data(sb_selected_data)
    );
    
    mux4to1_32bit sb_mask_mux (
        .i_data0({28'b0, sb_mask[0]}), .i_data1({28'b0, sb_mask[1]}),
        .i_data2({28'b0, sb_mask[2]}), .i_data3({28'b0, sb_mask[3]}),
        .i_sel(i_addr_offset),
        .o_data(sb_mask_mux_out)  
    );
    assign sb_selected_mask = sb_mask_mux_out[3:0];
    
    logic [31:0] sh_data [0:1];
    logic [3:0]  sh_mask [0:1];
    
    assign sh_data[0] = {16'b0, i_st_data[15:0]};
    assign sh_data[1] = {i_st_data[15:0], 16'b0};
    assign sh_mask[0] = 4'b0011;
    assign sh_mask[1] = 4'b1100;
    
    logic [31:0] sh_selected_data;
    logic [3:0]  sh_selected_mask;
    logic [31:0] sh_mask_mux_out; 
    
    mux2to1_32bit sh_data_mux (
        .i_data0(sh_data[0]), .i_data1(sh_data[1]),
        .i_sel(i_addr_offset[1]),
        .o_data(sh_selected_data)
    );
    
    mux2to1_32bit sh_mask_mux (
        .i_data0({28'b0, sh_mask[0]}), .i_data1({28'b0, sh_mask[1]}),
        .i_sel(i_addr_offset[1]),
        .o_data(sh_mask_mux_out)  
    );
    assign sh_selected_mask = sh_mask_mux_out[3:0];  
    
    logic [31:0] sw_data;
    logic [3:0]  sw_mask;
    assign sw_data = i_st_data;
    assign sw_mask = 4'b1111;
    
    logic [31:0] mask_final_mux_out;  
    
    mux4to1_32bit data_final_mux (
        .i_data0(sb_selected_data),
        .i_data1(sh_selected_data),
        .i_data2(sw_data),
        .i_data3(32'b0),
        .i_sel(i_store_type),
        .o_data(o_mem_wdata)
    );
    
    mux4to1_32bit mask_final_mux (
        .i_data0({28'b0, sb_selected_mask}),
        .i_data1({28'b0, sh_selected_mask}),
        .i_data2({28'b0, sw_mask}),
        .i_data3(32'b0),
        .i_sel(i_store_type),
        .o_data(mask_final_mux_out)  
    );
    assign o_byte_mask = mask_final_mux_out[3:0];
    
endmodule
