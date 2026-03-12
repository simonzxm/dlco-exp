module alu_s (
    input [3:0] A,
    input [3:0] B,
    input [2:0] ALUctr,
    output reg [3:0] F,
    output reg cf,
    output reg zero,
    output reg of
);

  //add your code here
  always @(A or B or ALUctr) begin
    case (ALUctr)
      3'b000: begin
        {cf, F} = A + B;
        of = (A[3] == B[3]) && (F[3] != A[3]);
        zero = ~(|F);
      end
      3'b001: begin
        {cf, F} = A - B;
        of = (A[3] != B[3]) && (F[3] != A[3]);
        zero = ~(|F);
      end
      3'b010: F = ~A;
      3'b011: F = A & B;
      3'b100: F = A | B;
      3'b101: F = A ^ B;
      3'b110: F = $signed(A) < $signed(B);
      3'b111: F = A == B;
      default: begin
        F = 4'd0;
        cf = 1'd0;
        of = 1'd0;
        zero = 1'd0;
      end
    endcase
  end

endmodule
