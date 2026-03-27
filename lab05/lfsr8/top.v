module top (
    input CLK100MHZ,
    input [8:0] SW,
    input BTNC,
    output [6:0] SEG,
    output [7:0] AN
);

wire [7:0] dout;

lfsr lfsr_inst (
    .seed(SW[7:0]),
    .clk(BTNC),
    .load(SW[8]),
    .dout(dout)
);

display display_inst (
    .clk(CLK100MHZ),
    .data({24'd0, dout}),
    .an(AN),
    .seg(SEG)
);

endmodule