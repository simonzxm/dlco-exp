module regfile (
    input [4:0] ra,
    input [4:0] rb,
    input [4:0] rw,
    input [31:0] wrdata,
    input regwr,
    input wrclk,
    output [31:0] outa,
    output [31:0] outb
);

  //The regfile
  reg [31:0] regs[31:0];

  //add your code here
  assign outa = ra ? regs[ra] : 32'd0;
  assign outb = rb ? regs[rb] : 32'd0;
  always @(posedge wrclk) if (regwr) regs[rw] = rw ? wrdata : 32'd0;

endmodule
