module timer (
    input clk,
    input en_1s,
    input start,
    input pause,
    input reset,
    output reg [7:0] second
);

  reg running;

  always @(posedge clk) begin
    if (reset) begin
      second  <= 8'd0;
      running <= 0;
    end else if (start) begin
      running <= 1;
    end else if (pause) begin
      running <= 0;
    end else if (running && en_1s) begin
      if (second[3:0] == 9) begin
        second[3:0] <= 0;
        second[7:4] <= (second[7:4] == 5) ? 0 : (second[7:4] + 1);
      end else begin
        second <= second + 1;
      end
    end
  end

endmodule
