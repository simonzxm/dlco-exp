module barrel (
    input [31:0] indata,
    input [4:0] shamt,
    input lr,
    input al,
    output reg [31:0] outdata
);

  always @(*) begin
    if (lr) outdata = indata << shamt;
    else if (al) outdata = ($signed(indata)) >>> shamt;
    else outdata = indata >> shamt;
  end

endmodule
