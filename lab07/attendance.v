module attendance (
    input [127:0] name,
    input clk,
    input rst,
    input [1:0] cmd,
    output reg [127:0] dataout
);

  // add your code here
  reg [127:0] sum;
  always @(posedge clk) begin
    if (rst) sum <= 128'b0;
    else if (cmd == 2'd1) sum <= sum + name;
    else if (cmd == 2'd2) sum <= sum - name;
    else dataout <= sum;
  end

endmodule
