module top (
    input CLK100MHZ,
    input BTNL,
    input BTNC,
    input BTNR,
    output LED,
    output [6:0] SEG,
    output [7:0] AN
);

  wire tick_10ms;
  wire tick_1s;

  tick_gen #(
      .MAX_COUNT(32'd999999)
  ) tick_gen_10ms (
      .clk (CLK100MHZ),
      .tick(tick_10ms)
  );

  tick_gen #(
      .MAX_COUNT(32'd99999999)
  ) tick_gen_1s (
      .clk (CLK100MHZ),
      .tick(tick_1s)
  );

  wire start;
  wire pause;
  wire reset;

  button btn_start (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNL),
      .btn_edge(start)
  );

  button btn_pause (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNC),
      .btn_edge(pause)
  );

  button btn_reset (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNR),
      .btn_edge(reset)
  );

  wire [7:0] timer_value;

  timer timer_inst (
      .clk(CLK100MHZ),
      .tick_1s(tick_1s),
      .start(start),
      .pause(pause),
      .reset(reset),
      .value(timer_value),
      .led(LED)
  );

  display display_inst (
      .clk(CLK100MHZ),
      .data({24'd0, timer_value}),
      .an(AN),
      .seg(SEG)
  );

endmodule
