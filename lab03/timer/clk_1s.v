module clk_1s (
    input  wire clk,
    output reg  clk_1s
);

  reg [26:0] counter;

  always @(posedge clk) begin
    if (counter == 99999999) begin
      counter <= 0;
      clk_1s  <= 1;
    end else begin
      counter <= counter + 1;
      clk_1s  <= 0;
    end
  end

endmodule
