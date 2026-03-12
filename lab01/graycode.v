module graycode (
    input  [63:0] B,
    output [63:0] G
);

  assign G = B ^ (B >> 1);

endmodule
