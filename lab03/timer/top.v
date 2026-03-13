module top (
    input CLK100MHZ,
    input BTNL,
    input BTNC,
    input BTNR,
    output [6:0] SEG,
    output [7:0] AN
);

  wire clk;
  wire [7:0] second;

  wire start;
  wire pause;
  wire reset;

  button start_btn (
      .clk(CLK100MHZ),
      .btn(BTNL),
      .btn_edge(start)
  );

  button pause_btn (
      .clk(CLK100MHZ),
      .btn(BTNC),
      .btn_edge(pause)
  );

  button reset_btn (
      .clk(CLK100MHZ),
      .btn(BTNR),
      .btn_edge(reset)
  );

  clk_1s clock (
      .clk(CLK100MHZ),
      .clk_1s(clk)
  );

  timer seconds (
      .clk(clk),
      .second(second),
      .start(start),
      .pause(pause),
      .reset(reset)
  );

  display numbers (
      .clk (CLK100MHZ),
      .data({24'd0, second}),
      .an  (AN),
      .seg (SEG)
  );

endmodule
