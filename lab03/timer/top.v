module top (
    input CLK100MHZ,
    output [6:0] SEG,
    output [7:0] AN
);

  wire clk;
  wire [7:0] second;

  clk_1s clock (
      .clk(CLK100MHZ),
      .clk_1s(clk)
  );

  timer seconds (
      .clk(clk),
      .second(second)
  );

  display numbers (
      .clk (CLK100MHZ),
      .data({24'd0, second}),
      .an  (AN),
      .seg (SEG)
  );

endmodule
