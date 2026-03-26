module top (
    input        CLK100MHZ,
    input  [8:0] SW,
    input        BTNC,
    input        BTNU,
    output [6:0] SEG,
    output [7:0] AN
);

  wire [3:0] addr = SW[3:0];
  wire [7:0] wdata = {4'b0000, SW[7:4]};
  wire       sel = SW[8];
  wire       reg_we = BTNU & ~sel;
  wire       ram_we = BTNU & sel;

  wire [7:0] reg_rdata;
  regfile regfile_inst (
      .clk  (BTNC),
      .we   (reg_we),
      .addr (addr),
      .wdata(wdata),
      .rdata(reg_rdata)
  );

  wire [7:0] ram_rdata;
  blk_mem_gen_0 ram_inst (
      .clka (BTNC),
      .wea  (ram_we),
      .addra(addr),
      .dina (wdata),
      .douta(ram_rdata)
  );

  wire [31:0] display_data = {
    4'h0, 4'h0, ram_rdata[7:4], ram_rdata[3:0], 4'h0, 4'h0, reg_rdata[7:4], reg_rdata[3:0]
  };
  display display_inst (
      .clk (CLK100MHZ),
      .data(display_data),
      .an  (AN),
      .seg (SEG)
  );

endmodule
