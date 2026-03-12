module top (
    input [10:0] SW,
    input CLK100MHZ,
    output [2:0] LED,
    output [6:0] SEG,
    output [7:0] AN
);

  wire [3:0] F;

  alu_s calc (
      .A(SW[10:7]),
      .B(SW[6:3]),
      .ALUctr(SW[2:0]),
      .F(F),
      .cf(LED[0]),
      .zero(LED[1]),
      .of(LED[2])
  );

  display result (
      .clk (CLK100MHZ),
      .data({28'd0, F}),
      .an  (AN),
      .seg (SEG)
  );

endmodule
