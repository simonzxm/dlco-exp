module timer (
    input clk,
    output reg [7:0] second
);

  always @(posedge clk) begin
    if (second[3:0] == 9) begin
      second[3:0] <= 0;
      second[7:4] <= (second[7:4] == 5) ? 0 : (second[7:4] + 1);
    end else second <= second + 1;
  end

endmodule
