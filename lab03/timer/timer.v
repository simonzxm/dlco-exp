module timer (
    input clk,
    input tick_1s,
    input start,
    input pause,
    input reset,
    output reg [7:0] value,
    output reg led
);

  reg running = 0;
  reg [3:0] ones = 0;
  reg [3:0] tens = 0;

  always @(posedge clk) begin
    if (reset) begin
      running <= 0;
    end else if (start) begin
      running <= 1;
    end else if (pause) begin
      running <= 0;
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      ones <= 0;
      tens <= 0;
      led  <= 0;
    end else if (running && tick_1s) begin
      if (ones == 9) begin
        ones <= 0;
        if (tens == 5) begin
          tens <= 0;
          led  <= 1;
        end else begin
          tens <= tens + 1;
          led  <= 0;
        end
      end else begin
        ones <= ones + 1;
        led  <= 0;
      end
    end
  end

  always @(*) begin
    value = {tens, ones};
  end

endmodule
