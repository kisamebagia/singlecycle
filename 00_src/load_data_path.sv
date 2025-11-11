module load_data_path (
    input  logic [31:0] i_mem_data,    
    input  logic [1:0]  i_addr_offset,  
    input  logic [2:0]  i_load_type,    
    output logic [31:0] o_load_data
);
    localparam [2:0] LOAD_BYTE  = 3'b000;  // LB
    localparam [2:0] LOAD_HALF  = 3'b001;  // LH
    localparam [2:0] LOAD_WORD  = 3'b010;  // LW
    localparam [2:0] LOAD_BYTEU = 3'b100;  // LBU
    localparam [2:0] LOAD_HALFU = 3'b101;  // LHU
    
    logic [7:0] selected_byte;
    logic [31:0] byte_mux_out;  
    
    mux4to1_32bit byte_mux (
        .i_data0({24'b0, i_mem_data[7:0]}),
        .i_data1({24'b0, i_mem_data[15:8]}),
        .i_data2({24'b0, i_mem_data[23:16]}),
        .i_data3({24'b0, i_mem_data[31:24]}),
        .i_sel(i_addr_offset),
        .o_data(byte_mux_out)  
    );
    assign selected_byte = byte_mux_out[7:0]; 
    
    logic [15:0] selected_half;
    logic [31:0] half_mux_out; 
    
    mux2to1_32bit half_mux (
        .i_data0({16'b0, i_mem_data[15:0]}),
        .i_data1({16'b0, i_mem_data[31:16]}),
        .i_sel(i_addr_offset[1]),
        .o_data(half_mux_out) 
    );
    assign selected_half = half_mux_out[15:0]; 
    
    logic [31:0] byte_signed, byte_unsigned;
    logic [31:0] half_signed, half_unsigned;
    
    assign byte_signed   = {{24{selected_byte[7]}}, selected_byte};
    assign byte_unsigned = {24'b0, selected_byte};
    assign half_signed   = {{16{selected_half[15]}}, selected_half};
    assign half_unsigned = {16'b0, selected_half};
    
    mux8to1_32bit result_mux (
        .i_data0(byte_signed),
        .i_data1(half_signed),
        .i_data2(i_mem_data),     
        .i_data3(32'b0),
        .i_data4(byte_unsigned),
        .i_data5(half_unsigned),
        .i_data6(32'b0),
        .i_data7(32'b0),
        .i_sel(i_load_type),
        .o_data(o_load_data)
    );
    
endmodule
