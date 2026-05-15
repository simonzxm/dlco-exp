module rv32is (
    input clock,
    input reset,
    output [31:0] imemaddr,
    input [31:0] imemdataout,
    output imemclk,
    output [31:0] dmemaddr,
    input [31:0] dmemdataout,
    output [31:0] dmemdatain,
    output dmemrdclk,
    output dmemwrclk,
    output [2:0] dmemop,
    output dmemwe,
    output [31:0] dbgdata
);

  assign imemclk   = ~clock;
  assign dmemrdclk = clock;
  assign dmemwrclk = ~clock;

  wire [6:0] op = imemdataout[6:0];
  wire [4:0] rs1 = imemdataout[19:15];
  wire [4:0] rs2 = imemdataout[24:20];
  wire [4:0] rd = imemdataout[11:7];
  wire [2:0] func3 = imemdataout[14:12];
  wire [6:0] func7 = imemdataout[31:25];

  wire [31:0] immI = {{20{imemdataout[31]}}, imemdataout[31:20]};
  wire [31:0] immU = {imemdataout[31:12], 12'b0};
  wire [31:0] immS = {{20{imemdataout[31]}}, imemdataout[31:25], imemdataout[11:7]};
  wire [31:0] immB = {
    {20{imemdataout[31]}}, imemdataout[7], imemdataout[30:25], imemdataout[11:8], 1'b0
  };
  wire [31:0] immJ = {
    {12{imemdataout[31]}}, imemdataout[19:12], imemdataout[20], imemdataout[30:21], 1'b0
  };

  reg [31:0] imm;
  reg [2:0] ExtOP;
  reg RegWr;
  reg ALUAsrc;
  reg [1:0] ALUBsrc;
  reg [3:0] ALUctr;
  reg [2:0] Branch;
  reg MemtoReg;
  reg MemWr;
  reg [2:0] MemOP;

  always @(*) begin
    case (ExtOP)
      3'b000:  imm = immI;
      3'b001:  imm = immU;
      3'b010:  imm = immS;
      3'b011:  imm = immB;
      3'b100:  imm = immJ;
      default: imm = 32'b0;
    endcase
  end

  always @(op[6:2] or func3 or func7[5]) begin
    ExtOP    = 3'b0;
    RegWr    = 1'b0;
    ALUAsrc  = 1'b0;
    ALUBsrc  = 2'b0;
    ALUctr   = 4'b0;
    Branch   = 3'b0;
    MemtoReg = 1'b0;
    MemWr    = 1'b0;
    MemOP    = 3'b0;
    case (op[6:2])
      5'b01101: begin
        ExtOP = 3'b001;
        RegWr = 1'b1;
        Branch = 3'b000;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        ALUBsrc = 2'b01;
        ALUctr = 4'b0011;
      end
      5'b00101: begin
        ExtOP = 3'b001;
        RegWr = 1'b1;
        Branch = 3'b000;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        ALUAsrc = 1'b1;
        ALUBsrc = 2'b01;
        ALUctr = 4'b0000;
      end
      5'b00100: begin
        ExtOP = 3'b000;
        RegWr = 1'b1;
        Branch = 3'b000;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        ALUAsrc = 1'b0;
        ALUBsrc = 2'b01;
        case (func3)
          3'b000: ALUctr = 4'b0000;
          3'b010: ALUctr = 4'b0010;
          3'b011: ALUctr = 4'b1010;
          3'b100: ALUctr = 4'b0100;
          3'b110: ALUctr = 4'b0110;
          3'b111: ALUctr = 4'b0111;
          3'b001: ALUctr = 4'b0001;
          3'b101: ALUctr = func7[5] ? 4'b1101 : 4'b0101;
        endcase
      end
      5'b01100: begin
        RegWr = 1'b1;
        Branch = 3'b000;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        ALUAsrc = 1'b0;
        ALUBsrc = 2'b00;
        case (func3)
          3'b000: ALUctr = func7[5] ? 4'b1000 : 4'b0000;
          3'b001: ALUctr = 4'b0001;
          3'b010: ALUctr = 4'b0010;
          3'b011: ALUctr = 4'b1010;
          3'b100: ALUctr = 4'b0100;
          3'b101: ALUctr = func7[5] ? 4'b1101 : 4'b0101;
          3'b110: ALUctr = 4'b0110;
          3'b111: ALUctr = 4'b0111;
        endcase
      end
      5'b11011: begin
        ExtOP = 3'b100;
        RegWr = 1'b1;
        Branch = 3'b001;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        ALUAsrc = 1'b1;
        ALUBsrc = 2'b10;
        ALUctr = 4'b0000;
      end
      5'b11001: begin
        ExtOP = 3'b000;
        RegWr = 1'b1;
        Branch = 3'b010;
        MemtoReg = 1'b0;
        MemWr = 1'b0;
        ALUAsrc = 1'b1;
        ALUBsrc = 2'b10;
        ALUctr = 4'b0000;
      end
      5'b11000: begin
        ExtOP = 3'b011;
        RegWr = 1'b0;
        MemtoReg = 1'b0;
        ALUAsrc = 1'b0;
        ALUBsrc = 2'b00;
        case (func3)
          3'b000: begin
            Branch = 3'b100;
            ALUctr = 4'b0010;
          end
          3'b001: begin
            Branch = 3'b101;
            ALUctr = 4'b0010;
          end
          3'b100: begin
            Branch = 3'b110;
            ALUctr = 4'b0010;
          end
          3'b101: begin
            Branch = 3'b111;
            ALUctr = 4'b0010;
          end
          3'b110: begin
            Branch = 3'b110;
            ALUctr = 4'b1010;
          end
          3'b111: begin
            Branch = 3'b111;
            ALUctr = 4'b1010;
          end
        endcase
      end
      5'b00000: begin
        ExtOP = 3'b000;
        RegWr = 1'b1;
        Branch = 3'b000;
        MemtoReg = 1'b1;
        MemWr = 1'b0;
        MemOP = func3;
        ALUAsrc = 1'b0;
        ALUBsrc = 2'b01;
        ALUctr = 4'b0000;
      end
      5'b01000: begin
        ExtOP   = 3'b010;
        RegWr   = 1'b0;
        Branch  = 3'b000;
        MemWr   = 1'b1;
        MemOP   = func3;
        ALUAsrc = 1'b0;
        ALUBsrc = 2'b01;
        ALUctr  = 4'b0000;
      end
    endcase
  end

  wire [31:0] rd1;
  wire [31:0] rd2;
  reg [31:0] PC;
  reg [31:0] nextPC;

  wire [31:0] dataa = (ALUAsrc == 1'b0) ? rd1 : PC;
  wire [31:0] datab = (ALUBsrc == 2'b00) ? rd2 : (ALUBsrc == 2'b01) ? imm : 32'd4;
  wire zero;
  wire less;
  wire [31:0] aluresult;

  alu alu_inst (
      .dataa(dataa),
      .datab(datab),
      .ALUctr(ALUctr),
      .less(less),
      .zero(zero),
      .aluresult(aluresult)
  );

  regfile regfile_inst (
      .clk(clock),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .datain(dmemdataout),
      .aluresult(aluresult),
      .RegWr(RegWr),
      .MemtoReg(MemtoReg),
      .rd1(rd1),
      .rd2(rd2)
  );

  initial PC = 32'b0;

  always @(*) begin
    case (Branch)
      3'b000:  nextPC = PC + 4;
      3'b001:  nextPC = PC + imm;
      3'b010:  nextPC = rd1 + imm;
      3'b100:  nextPC = zero ? PC + imm : PC + 4;
      3'b101:  nextPC = zero ? PC + 4 : PC + imm;
      3'b110:  nextPC = less ? PC + imm : PC + 4;
      3'b111:  nextPC = less ? PC + 4 : PC + imm;
      default: nextPC = PC + 4;
    endcase
  end

  always @(negedge clock) begin
    if (reset) PC <= 32'b0;
    else PC <= nextPC;
  end

  assign imemaddr = reset ? 32'b0 : nextPC;
  assign dmemaddr = aluresult;
  assign dmemdatain = rd2;
  assign dmemwe = MemWr;
  assign dmemop = MemOP;
  assign dbgdata = regfile_inst.regs[10];

endmodule
