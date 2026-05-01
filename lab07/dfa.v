module dfa (
    input clk,
    input [7:0] data,
    input reset,
    output reg result
);

  //add your code here
  reg [1:0] state;

  initial begin
    state  <= 2'd0;
    result <= 1'd0;
  end

  always @(posedge clk) begin
    if (reset) begin
      state  <= 2'd0;
      result <= 1'd0;
    end else if (data == 8'd0) begin
      result = (state == 2'd1) ? 1'd1 : 1'd0;
    end else begin
      if (data == 8'h4e || data == 8'h6e) state = state ^ 2'd1;
      else state = state ^ 2'd2;
    end
  end

endmodule
