module top (
    input CLK100MHZ,
    input CPU_RESETN,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

  wire clk_25mhz;

  clk_wiz_0 u_clk_wiz (
      .clk_in1 (CLK100MHZ),
      .clk_out1(clk_25mhz)
  );

  wire [9:0] h_addr;
  wire [9:0] v_addr;
  wire valid;
  wire [11:0] vga_data;
  wire [18:0] rom_addr;

  assign rom_addr = h_addr + v_addr * 10'd640;

  image_rom image_rom_inst (
      .clka (clk_25mhz),
      .addra(rom_addr),
      .douta(vga_data)
  );

  vga_ctrl vga_ctrl_inst (
      .pclk(clk_25mhz),
      .reset(~CPU_RESETN),
      .vga_data(vga_data),
      .h_addr(h_addr),
      .v_addr(v_addr),
      .hsync(VGA_HS),
      .vsync(VGA_VS),
      .valid(valid),
      .vga_r(VGA_R),
      .vga_g(VGA_G),
      .vga_b(VGA_B)
  );

endmodule

