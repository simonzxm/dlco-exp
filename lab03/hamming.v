module hamming (
    input [6:0] code,
    output reg [6:0] correct,
    output [2:0] parity
);

  // add your code here
  assign parity[0] = code[0] ^ code[2] ^ code[4] ^ code[6];
  assign parity[1] = code[1] ^ code[2] ^ code[5] ^ code[6];
  assign parity[2] = code[3] ^ code[4] ^ code[5] ^ code[6];

  always @(*) begin
    if (parity) correct = code ^ (7'd1 << (parity - 3'd1));
    else correct = code;
  end

endmodule
