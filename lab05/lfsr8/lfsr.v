module lfsr (
    input [7:0] seed,
    input clk,
    input load,
    output reg [7:0] dout
);

  always @(posedge clk) begin
    if (load) dout <= seed;
    else dout <= {dout[4] ^ dout[3] ^ dout[2] ^ dout[0], dout[7:1]};
  end

endmodule
