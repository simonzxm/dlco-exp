module top (
    input         CLK100MHZ,
    input  [13:0] SW,
    input         BTNC,
    output [ 6:0] SEG,
    output [ 7:0] AN
);

  wire reg_we = SW[13] & ~SW[12];
  wire ram_we = SW[13] &  SW[12];

  wire [7:0] reg_rdata;
  regfile regfile_inst (
      .clk  (BTNC),
      .we   (reg_we),
      .addr (SW[3:0]),
      .wdata(SW[11:4]),
      .rdata(reg_rdata)
  );

  wire [7:0] ram_rdata;
  blk_mem_gen_0 ram_inst (
      .clka (BTNC),
      .wea  (ram_we),
      .addra(SW[3:0]),
      .dina (SW[11:4]),
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
