module top (
    input         CLK100MHZ,
    input  [11:0] SW,
    output [ 6:0] SEG,
    output [ 7:0] AN,
    output [ 1:0] LED
);

  wire [ 3:0] aluctr = SW[11:8];

  wire [31:0] dataa = {8{SW[3:0]}};
  wire [31:0] datab = {8{SW[7:4]}};

  wire        less;
  wire        zero;
  wire [31:0] aluresult;

  alu alu_inst (
      .dataa    (dataa),
      .datab    (datab),
      .ALUctr   (aluctr),
      .less     (less),
      .zero     (zero),
      .aluresult(aluresult)
  );

  assign LED[0] = zero;
  assign LED[1] = less;

  display display_inst (
      .clk (CLK100MHZ),
      .data(aluresult),
      .an  (AN),
      .seg (SEG)
  );

endmodule
