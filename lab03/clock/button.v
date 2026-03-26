module button (
    input  wire clk,
    input  wire tick_10ms,
    input  wire btn,
    output wire btn_edge
);

  // Synchronize & Debounce
  reg delay1 = 1'b0;
  reg delay2 = 1'b0;
  always @(posedge clk) begin
    if (tick_10ms) begin
      delay1 <= btn;
      delay2 <= delay1;
    end
  end
  wire btn_stable = delay1 & delay2;

  // Posedge Detect
  reg  stable_delay = 1'b0;
  always @(posedge clk) begin
    stable_delay <= btn_stable;
  end
  assign btn_edge = btn_stable & ~stable_delay;

endmodule
