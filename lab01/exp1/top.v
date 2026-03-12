module top (
    input  wire [9:0] SW,
    output wire [1:0] LED
);

  exp1 selector (
      .X0(SW[9:8]),
      .X1(SW[7:6]),
      .X2(SW[5:4]),
      .X3(SW[3:2]),
      .Y (SW[1:0]),
      .F (LED)
  );

endmodule
