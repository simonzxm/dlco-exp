module alu (
    input [31:0] dataa,
    input [31:0] datab,
    input [3:0] ALUctr,
    output less,
    output zero,
    output reg [31:0] aluresult
);

  //add your code here
  wire [4:0] shamt = datab[4:0];

  assign less = (ALUctr[3] == 1'b0) ? ($signed(dataa) < $signed(datab)) : (dataa < datab);
  assign zero = (ALUctr[2:0] == 3'b010) ? (dataa == datab) : (aluresult == 32'b0);

  always @(*) begin
    casez (ALUctr)
      4'b0000: aluresult = dataa + datab;
      4'b1000: aluresult = dataa - datab;
      4'b?001: aluresult = dataa << shamt;
      4'b?010: aluresult = {31'b0, less};
      4'b?011: aluresult = datab;
      4'b?100: aluresult = dataa ^ datab;
      4'b0101: aluresult = dataa >> shamt;
      4'b1101: aluresult = $signed(dataa) >>> shamt;
      4'b?110: aluresult = dataa | datab;
      4'b?111: aluresult = dataa & datab;
      default: aluresult = 32'b0;
    endcase
  end

endmodule
