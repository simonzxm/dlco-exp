module lfsr (
    input [63:0] seed,
    input clk,
    input load,
    output reg [63:0] dout
);

  //add your code here
  always @(posedge clk) begin
    if (load) dout <= seed;
    else dout <= {dout[4] ^ dout[3] ^ dout[1] ^ dout[0], dout[63:1]};
  end

endmodule
