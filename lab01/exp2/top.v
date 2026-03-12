module top (
    input  wire [8:0] SW,
    output wire [6:0] SEG,
    output wire [4:0] LED
);

  enhanced encoder (
      .X(SW[7:0]),
      .en(SW[8]),
      .valid(LED[4]),
      .value(LED[3:0]),
      .F(SEG[6:0])
  );

endmodule
