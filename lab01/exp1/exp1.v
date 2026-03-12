module exp1 (
    input [1:0] X0,
    input [1:0] X1,
    input [1:0] X2,
    input [1:0] X3,
    input [1:0] Y,
    output reg [1:0] F
);

  //add your code here
  always @(X0 or X1 or X2 or X3 or Y)
    case (Y)
      0: F = X0;
      1: F = X1;
      2: F = X2;
      3: F = X3;
      default: F = 2'b0;
    endcase

endmodule
