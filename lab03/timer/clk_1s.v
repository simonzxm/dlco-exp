module clk_1s (
    input  wire clk,
    output reg  clk_1s
);

  reg [25:0] counter;

  always @(posedge clk) begin
    if (counter == 49999999) begin
      counter <= 0;
      clk_1s  <= ~clk_1s;
    end else counter <= counter + 1;
  end

endmodule
