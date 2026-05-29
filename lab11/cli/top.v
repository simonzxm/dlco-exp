module top (
    input CLK100MHZ,
    input CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

  wire [7:0] ascii_key;
  wire [7:0] key_count;

  keyboard key_inst (
      .clk(CLK100MHZ),
      .clrn(CPU_RESETN),
      .ps2_clk(PS2_CLK),
      .ps2_data(PS2_DATA),
      .key_count(key_count),
      .ascii_key(ascii_key)
  );

  wire clk_25mhz;

  clk_wiz_0 u_clk_wiz (
      .clk_in1 (CLK100MHZ),
      .clk_out1(clk_25mhz)
  );

  wire [9:0] h_addr;
  wire [9:0] v_addr;
  wire [11:0] vga_data;

  cli cli_inst (
      .clk(CLK100MHZ),
      .ascii_key(ascii_key),
      .key_count(key_count),
      .h_addr(h_addr),
      .v_addr(v_addr),
      .vga_data(vga_data)
  );

  vga_ctrl vga_ctrl_inst (
      .pclk(clk_25mhz),
      .reset(~CPU_RESETN),
      .vga_data(vga_data),
      .h_addr(h_addr),
      .v_addr(v_addr),
      .hsync(VGA_HS),
      .vsync(VGA_VS),
      .vga_r(VGA_R),
      .vga_g(VGA_G),
      .vga_b(VGA_B)
  );

endmodule
