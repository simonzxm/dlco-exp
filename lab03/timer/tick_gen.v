module tick_gen #(
    parameter MAX_COUNT = 32'd99999
) (
    input  wire clk,
    output wire tick
);

  reg [31:0] cnt = 0;

  always @(posedge clk) begin
    if (cnt >= MAX_COUNT) cnt <= 32'd0;
    else cnt <= cnt + 1;
  end

  assign tick = (cnt == MAX_COUNT);

endmodule
