module regfile (
    input clk,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] datain,
    input [31:0] aluresult,
    input RegWr,
    input MemtoReg,
    output [31:0] rd1,
    output [31:0] rd2
);

  reg [31:0] regs[31:0];

  assign rd1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
  assign rd2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

  always @(negedge clk) begin
    if (RegWr && rd != 5'b0) begin
      regs[rd] <= (MemtoReg == 1'b0) ? aluresult : datain;
    end
  end

endmodule
