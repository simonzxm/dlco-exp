module top (
    input         CLK100MHZ,
    input  [15:0] SW,
    output [ 6:0] SEG,
    output [ 7:0] AN
);

  wire [31:0] dataout;

  dmem dmem_inst (
      .addr   ({13'b0, SW[14:11]}),
      .dataout(dataout),
      .datain ({4{SW[7:0]}}),
      .clk    (CLK100MHZ),
      .memop  (SW[10:8]),
      .we     (SW[15])
  );

  display display_inst (
      .clk (CLK100MHZ),
      .data(dataout),
      .an  (AN),
      .seg (SEG)
  );

endmodule
