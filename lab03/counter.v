module counter (
    input clk,
    input en,
    input rst,
    input [3:0] cnt_limit,
    output reg [3:0] Q,
    output reg rco
);

  // add your code here
  always @(posedge clk) begin
    if (en) begin
      if (rst) begin
        Q   <= 4'b0;
        rco <= 1'b0;
      end else begin
        if (Q == cnt_limit - 1) begin
          Q   <= 4'b0;
          rco <= 1'b1;
        end else begin
          Q   <= Q + 1'b1;
          rco <= 1'b0;
        end
      end
    end
  end

endmodule
