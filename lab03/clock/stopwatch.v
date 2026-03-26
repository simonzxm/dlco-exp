module stopwatch (
    input wire clk,
    input wire tick_10ms,
    input wire start_pause,
    input wire reset,
    output reg [3:0] min_tens,
    output reg [3:0] min_ones,
    output reg [3:0] sec_tens,
    output reg [3:0] sec_ones,
    output reg [3:0] csec_tens,
    output reg [3:0] csec_ones
);

  reg running = 0;

  always @(posedge clk) begin
    if (reset && !running) begin
      running <= 0;
    end else if (start_pause) begin
      running <= ~running;
    end
  end

  wire csec_carry = (csec_tens == 9) && (csec_ones == 9);
  wire sec_carry = (sec_tens == 5) && (sec_ones == 9);

  // Centisecond
  always @(posedge clk) begin
    if (reset && !running) begin
      csec_tens <= 0;
      csec_ones <= 0;
    end else if (running && tick_10ms) begin
      if (csec_ones == 9) begin
        csec_ones <= 0;
        if (csec_tens == 9) csec_tens <= 0;
        else csec_tens <= csec_tens + 1;
      end else begin
        csec_ones <= csec_ones + 1;
      end
    end
  end

  // Second
  always @(posedge clk) begin
    if (reset && !running) begin
      sec_tens <= 0;
      sec_ones <= 0;
    end else if (running && tick_10ms && csec_carry) begin
      if (sec_ones == 9) begin
        sec_ones <= 0;
        if (sec_tens == 5) sec_tens <= 0;
        else sec_tens <= sec_tens + 1;
      end else begin
        sec_ones <= sec_ones + 1;
      end
    end
  end

  // Minute
  always @(posedge clk) begin
    if (reset && !running) begin
      min_tens <= 0;
      min_ones <= 0;
    end else if (running && tick_10ms && csec_carry && sec_carry) begin
      if (min_ones == 9) begin
        min_ones <= 0;
        if (min_tens == 5) min_tens <= 0;
        else min_tens <= min_tens + 1;
      end else begin
        min_ones <= min_ones + 1;
      end
    end
  end

endmodule
