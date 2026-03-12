module adder (
    input [3:0] A,
    input [3:0] B,
    input addsub,
    output [3:0] F,
    output cf,
    output zero,
    output of
);

  // add your code here
  assign {cf, F} = addsub ? (A - B) : (A + B);
  assign of = (addsub ^ (A[3] == B[3])) && (F[3] != A[3]);
  assign zero = ~(|F);

endmodule
