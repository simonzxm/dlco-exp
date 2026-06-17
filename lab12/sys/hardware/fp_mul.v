module fp_mul (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] y
);

  wire sa = a[31], sb = b[31];
  wire [7:0] ea = a[30:23], eb = b[30:23];
  wire [23:0] ma = {1'b1, a[22:0]}, mb = {1'b1, b[22:0]};
  wire azero = (a[30:0] == 31'b0), bzero = (b[30:0] == 31'b0);

  wire [47:0] prod = ma * mb;
  wire norm = prod[47];
  wire [47:0] pn = norm ? prod : (prod << 1);
  wire [22:0] mant = pn[46:24];
  wire [9:0] esum = {2'b0, ea} + {2'b0, eb} + {9'b0, norm} - 10'd127;

  assign y = (azero | bzero) ? 32'b0 : {sa ^ sb, esum[7:0], mant};

endmodule
