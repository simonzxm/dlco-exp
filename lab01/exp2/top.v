module top (
    input  wire [8:0] SW,
    output wire [6:0] SEG,
    output wire [4:0] LED,
    output wire [7:0] AN
);

  assign AN = 8'b11111110;

  enhanced encoder (
      .X(SW[7:0]),
      .en(SW[8]),
      .valid(LED[4]),
      .value(LED[3:0]),
      .F(SEG[6:0])
  );

endmodule
