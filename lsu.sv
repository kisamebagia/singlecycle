// ============================================================================
// LSU Module - Compatible with word-addressed memory
// ============================================================================
module lsu (
  input  logic        i_clk,
  input  logic        i_reset,

  input  logic [31:0] i_lsu_addr,
  input  logic [31:0] i_st_data,
  input  logic        i_lsu_wren,
  input  logic [2:0]  i_func3,

  input  logic [31:0] i_io_sw,

  output logic [6:0]  o_io_hex0,
  output logic [6:0]  o_io_hex1,
  output logic [6:0]  o_io_hex2,
  output logic [6:0]  o_io_hex3,
  output logic [6:0]  o_io_hex4,
  output logic [6:0]  o_io_hex5,
  output logic [6:0]  o_io_hex6,
  output logic [6:0]  o_io_hex7,

  output logic [31:0] o_ld_data,

  output logic [31:0] o_io_ledr,
  output logic [31:0] o_io_ledg,
  output logic [31:0] o_io_lcd
);

  // =========================================================================
  // Internal Signals
  // =========================================================================
  logic        is_ledr, is_ledg, is_hex03, is_hex47, is_lcd, is_sw;
  logic        is_dmem, is_out, is_in;

  logic [15:0] dmem_ptr;
  logic        mem_wren;

  logic [3:0]  bmask_align, bmask_misalign;
  logic [31:0] dmem;
  logic [31:0] ld_data;

  // =========================================================================
  // Byte Mask Calculation for Misaligned Access
  // =========================================================================
  always_comb begin
    bmask_align = 4'b0;
    bmask_misalign = 4'b0;

    case (i_func3)
      // Byte operations (LB, LBU, SB)
      3'b000, 3'b100: begin
        case (i_lsu_addr[1:0])
          2'b00: bmask_align = 4'b0001;
          2'b01: bmask_align = 4'b0010;
          2'b10: bmask_align = 4'b0100;
          2'b11: bmask_align = 4'b1000;
        endcase
        bmask_misalign = 4'b0000;
      end

      // Halfword operations (LH, LHU, SH)
      3'b001, 3'b101: begin
        case (i_lsu_addr[1:0])
          2'b00: begin
            bmask_align = 4'b0011;
            bmask_misalign = 4'b0000;
          end
          2'b01: begin
            bmask_align = 4'b0110;
            bmask_misalign = 4'b0000;
          end
          2'b10: begin
            bmask_align = 4'b1100;
            bmask_misalign = 4'b0000;
          end
          2'b11: begin  // Misaligned halfword
            bmask_align = 4'b1000;
            bmask_misalign = 4'b0001;
          end
        endcase
      end

      // Word operations (LW, SW)
      3'b010: begin
        case (i_lsu_addr[1:0])
          2'b00: begin
            bmask_align = 4'b1111;
            bmask_misalign = 4'b0000;
          end
          2'b01: begin  // Misaligned word
            bmask_align = 4'b1110;
            bmask_misalign = 4'b0001;
          end
          2'b10: begin  // Misaligned word
            bmask_align = 4'b1100;
            bmask_misalign = 4'b0011;
          end
          2'b11: begin  // Misaligned word
            bmask_align = 4'b1000;
            bmask_misalign = 4'b0111;
          end
        endcase
      end

      default: begin
        bmask_align = 4'b1111;
        bmask_misalign = 4'b0000;
      end
    endcase
  end

  // =========================================================================
  // Address Decode (Memory Mapping)
  // =========================================================================
  assign dmem_ptr = i_lsu_addr[15:0];
  assign is_dmem  = ~i_lsu_addr[28];
  assign is_out   = (i_lsu_addr[28] && ~i_lsu_addr[16]);
  assign is_in    = (i_lsu_addr[28] &&  i_lsu_addr[16]);

  assign is_ledr  = is_out && (~i_lsu_addr[14] && ~i_lsu_addr[13] && ~i_lsu_addr[12]);
  assign is_ledg  = is_out && (~i_lsu_addr[14] && ~i_lsu_addr[13] &&  i_lsu_addr[12]);
  assign is_hex03 = is_out && (~i_lsu_addr[14] &&  i_lsu_addr[13] && ~i_lsu_addr[12]);
  assign is_hex47 = is_out && (~i_lsu_addr[14] &&  i_lsu_addr[13] &&  i_lsu_addr[12]);
  assign is_lcd   = is_out && ( i_lsu_addr[14] && ~i_lsu_addr[13] && ~i_lsu_addr[12]);
  assign is_sw    = is_in  && (~i_lsu_addr[14] && ~i_lsu_addr[13]);

  // =========================================================================
  // Memory Instance - Word-Addressed with Misaligned Support
  // =========================================================================
  memory u_memory (
    .i_clk           (i_clk),
    .i_reset         (i_reset),
    .i_func3         (i_func3),
    .i_addr          (dmem_ptr),
    .i_wdata         (i_st_data),
    .i_bmask_align   (bmask_align),
    .i_bmask_misalign(bmask_misalign),
    .i_wren          (mem_wren),
    .o_rdata         (dmem)
  );

  // =========================================================================
  // Data Path Control
  // =========================================================================
  always_comb begin
    mem_wren = 1'b0;
    ld_data  = 32'b0;

    // -------------------------------
    // MEMORY ACCESS
    // -------------------------------
    if (is_dmem) begin
      if (i_lsu_wren) begin
        mem_wren = 1'b1;  // Memory handles data preparation internally
      end else begin
        ld_data = dmem;  // Memory handles load data assembly internally
      end
    end 
    
    // -------------------------------
    // PERIPHERAL ACCESS (READ)
    // -------------------------------
    else if (!i_lsu_wren) begin
      if (is_sw) begin
        ld_data = i_io_sw;
      end else if (is_ledr) begin
        ld_data = o_io_ledr;
      end else if (is_ledg) begin
        ld_data = o_io_ledg;
      end else if (is_lcd) begin
        ld_data = o_io_lcd;
      end else if (is_hex03) begin
        ld_data = {1'b0, o_io_hex3, 1'b0, o_io_hex2, 1'b0, o_io_hex1, 1'b0, o_io_hex0};
      end else if (is_hex47) begin
        ld_data = {1'b0, o_io_hex7, 1'b0, o_io_hex6, 1'b0, o_io_hex5, 1'b0, o_io_hex4};
      end else begin
        ld_data = 32'b0;
      end
    end
  end

  // =========================================================================
  // Peripheral Registers Update
  // =========================================================================
  always_ff @(posedge i_clk or negedge i_reset) begin
    if (!i_reset) begin
      o_io_ledr <= 32'b0;
      o_io_ledg <= 32'b0;
      o_io_lcd  <= 32'b0;
      o_io_hex0 <= 7'b1111111;
      o_io_hex1 <= 7'b1111111;
      o_io_hex2 <= 7'b1111111;
      o_io_hex3 <= 7'b1111111;
      o_io_hex4 <= 7'b1111111;
      o_io_hex5 <= 7'b1111111;
      o_io_hex6 <= 7'b1111111;
      o_io_hex7 <= 7'b1111111;
    end else if (i_lsu_wren) begin
      // Write to RED LEDs
      if (is_ledr) o_io_ledr <= i_st_data;
      
      // Write to GREEN LEDs
      if (is_ledg) o_io_ledg <= i_st_data;
      
      // Write to HEX 0-3
      if (is_hex03) begin
        case (bmask_align)
          4'b0001: o_io_hex0 <= i_st_data[6:0];
          4'b0010: o_io_hex1 <= i_st_data[6:0];
          4'b0100: o_io_hex2 <= i_st_data[6:0];
          4'b1000: o_io_hex3 <= i_st_data[6:0];
          4'b0011: begin
            o_io_hex0 <= i_st_data[6:0];
            o_io_hex1 <= i_st_data[14:8];
          end
          4'b0110: begin
            o_io_hex1 <= i_st_data[6:0];
            o_io_hex2 <= i_st_data[14:8];
          end
          4'b1100: begin
            o_io_hex2 <= i_st_data[6:0];
            o_io_hex3 <= i_st_data[14:8];
          end
          4'b1111: begin
            o_io_hex0 <= i_st_data[6:0];
            o_io_hex1 <= i_st_data[14:8];
            o_io_hex2 <= i_st_data[22:16];
            o_io_hex3 <= i_st_data[30:24];
          end
        endcase
      end
      
      // Write to HEX 4-7
      if (is_hex47) begin
        case (bmask_align)
          4'b0001: o_io_hex4 <= i_st_data[6:0];
          4'b0010: o_io_hex5 <= i_st_data[6:0];
          4'b0100: o_io_hex6 <= i_st_data[6:0];
          4'b1000: o_io_hex7 <= i_st_data[6:0];
          4'b0011: begin
            o_io_hex4 <= i_st_data[6:0];
            o_io_hex5 <= i_st_data[14:8];
          end
          4'b0110: begin
            o_io_hex5 <= i_st_data[6:0];
            o_io_hex6 <= i_st_data[14:8];
          end
          4'b1100: begin
            o_io_hex6 <= i_st_data[6:0];
            o_io_hex7 <= i_st_data[14:8];
          end
          4'b1111: begin
            o_io_hex4 <= i_st_data[6:0];
            o_io_hex5 <= i_st_data[14:8];
            o_io_hex6 <= i_st_data[22:16];
            o_io_hex7 <= i_st_data[30:24];
          end
        endcase
      end
      
      // Write to LCD
      if (is_lcd) o_io_lcd <= i_st_data;
    end
  end

  // =========================================================================
  // Output Assignment
  // =========================================================================
  assign o_ld_data = ld_data;

endmodule
