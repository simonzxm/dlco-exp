module top (
    input        CLK100MHZ,
    input        CPU_RESETN,
    input        PS2_CLK,
    input        PS2_DATA,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output       VGA_HS,
    output       VGA_VS
);

  wire reset = ~CPU_RESETN;

  // 25MHz pixel clock for VGA
  wire pclk;
  clk_wiz_0 u_clk (
      .clk_in1 (CLK100MHZ),
      .clk_out1(pclk)
  );

  wire [31:0] imemaddr, imemdataout;
  wire imemclk;
  wire [31:0] dmemaddr, dmemdatain, dmemdataout;
  wire dmemrdclk, dmemwrclk, dmemwe;
  wire [ 2:0] dmemop;
  wire [31:0] dbgdata;

  rv32ip cpu (
      .clock      (CLK100MHZ),
      .reset      (reset),
      .imemaddr   (imemaddr),
      .imemdataout(imemdataout),
      .imemclk    (imemclk),
      .dmemaddr   (dmemaddr),
      .dmemdataout(dmemdataout),
      .dmemdatain (dmemdatain),
      .dmemrdclk  (dmemrdclk),
      .dmemwrclk  (dmemwrclk),
      .dmemop     (dmemop),
      .dmemwe     (dmemwe),
      .dbgdata    (dbgdata)
  );

  // Instruction ROM
  blk_mem_gen_1 imem (
      .clka (imemclk),
      .addra(imemaddr[12:2]),
      .douta(imemdataout)
  );

  // Data RAM
  wire        dmem_we = dmemwe & (dmemaddr[31:20] == 12'h001);
  wire [31:0] dmem_out;
  dmem datamem (
      .addr   (dmemaddr[16:0]),
      .dataout(dmem_out),
      .datain (dmemdatain),
      .wrclk  (dmemwrclk),
      .rdclk  (dmemrdclk),
      .memop  (dmemop),
      .we     (dmem_we)
  );

  // VGA character buffer
  wire vga_we = dmemwe & (dmemaddr[31:20] == 12'h002);
  wire [9:0] h_addr, v_addr;
  wire [11:0] vga_data;
  vga_char vga (
      .wclk    (dmemwrclk),
      .we      (vga_we),
      .waddr   (dmemaddr[16:0]),
      .wdata   (dmemdatain[7:0]),
      .h_addr  (h_addr),
      .v_addr  (v_addr),
      .vga_data(vga_data)
  );

  // Keyboard
  wire [7:0] key_count, ascii_key;
  keyboard kbd (
      .clk      (CLK100MHZ),
      .clrn     (CPU_RESETN),
      .ps2_clk  (PS2_CLK),
      .ps2_data (PS2_DATA),
      .key_count(key_count),
      .ascii_key(ascii_key)
  );
  reg [31:0] key_reg;
  always @(posedge dmemrdclk) key_reg <= {16'b0, key_count, ascii_key};

  assign dmemdataout = (dmemaddr[31:20] == 12'h001) ? dmem_out :
                       (dmemaddr[31:20] == 12'h003) ? key_reg : 32'b0;

  // VGA output
  vga_ctrl vga_ctrl_inst (
      .pclk    (pclk),
      .reset   (reset),
      .vga_data(vga_data),
      .h_addr  (h_addr),
      .v_addr  (v_addr),
      .hsync   (VGA_HS),
      .vsync   (VGA_VS),
      .vga_r   (VGA_R),
      .vga_g   (VGA_G),
      .vga_b   (VGA_B)
  );

endmodule
