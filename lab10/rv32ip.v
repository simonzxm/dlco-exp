module rv32ip (
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

  assign imemclk   = clock;
  assign dmemrdclk = clock;
  assign dmemwrclk = ~clock;

  reg [31:0] PC_IF;
  wire [31:0] nextPC_IF;

  reg jump;
  reg [31:0] jump_target;
  wire stall;
  wire jump_real = jump && !stall;

  always @(negedge clock) begin
    if (reset) begin
      PC_IF <= 32'b0;
    end else if (!stall) begin
      PC_IF <= nextPC_IF;
    end
  end

  assign nextPC_IF = jump_real ? jump_target : stall ? PC_IF : (PC_IF + 4);

  assign imemaddr  = reset ? 32'b0 : PC_IF;

  reg [31:0] PC_ID;
  reg [31:0] inst;

  always @(negedge clock) begin
    if (reset || jump_real) begin
      PC_ID <= 32'b0;
      inst  <= 32'h00000013;
    end else if (!stall) begin
      PC_ID <= PC_IF;
      inst  <= imemdataout;
    end
  end

  wire [6:0] op_ID = inst[6:0];
  wire [4:0] rs1_ID = inst[19:15];
  wire [4:0] rs2_ID = inst[24:20];
  wire [4:0] rd_ID = inst[11:7];
  wire [2:0] func3_ID = inst[14:12];
  wire [6:0] func7_ID = inst[31:25];

  wire [31:0] immI = {{20{inst[31]}}, inst[31:20]};
  wire [31:0] immU = {inst[31:12], 12'b0};
  wire [31:0] immS = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  wire [31:0] immB = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [31:0] immJ = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

  reg [31:0] imm_ID;
  reg [2:0] ExtOP_ID;
  reg RegWr_ID;
  reg ALUAsrc_ID;
  reg [1:0] ALUBsrc_ID;
  reg [3:0] ALUctr_ID;
  reg [2:0] Branch_ID;
  reg MemtoReg_ID;
  reg MemWr_ID;
  reg [2:0] MemOP_ID;

  always @(*) begin
    case (ExtOP_ID)
      3'b000:  imm_ID = immI;
      3'b001:  imm_ID = immU;
      3'b010:  imm_ID = immS;
      3'b011:  imm_ID = immB;
      3'b100:  imm_ID = immJ;
      default: imm_ID = 32'b0;
    endcase
  end

  always @(*) begin
    ExtOP_ID    = 3'b000;
    RegWr_ID    = 1'b0;
    ALUAsrc_ID  = 1'b0;
    ALUBsrc_ID  = 2'b00;
    ALUctr_ID   = 4'b0000;
    Branch_ID   = 3'b000;
    MemtoReg_ID = 1'b0;
    MemWr_ID    = 1'b0;
    MemOP_ID    = 3'b000;

    if (inst != 32'h0) begin
      case (op_ID[6:2])
        5'b01101: begin
          ExtOP_ID   = 3'b001;
          RegWr_ID   = 1'b1;
          ALUBsrc_ID = 2'b01;
          ALUctr_ID  = 4'b0011;
        end
        5'b00101: begin
          ExtOP_ID   = 3'b001;
          RegWr_ID   = 1'b1;
          ALUAsrc_ID = 1'b1;
          ALUBsrc_ID = 2'b01;
          ALUctr_ID  = 4'b0000;
        end
        5'b00100: begin
          ExtOP_ID   = 3'b000;
          RegWr_ID   = 1'b1;
          ALUBsrc_ID = 2'b01;
          case (func3_ID)
            3'b000: ALUctr_ID = 4'b0000;
            3'b010: ALUctr_ID = 4'b0010;
            3'b011: ALUctr_ID = 4'b1010;
            3'b100: ALUctr_ID = 4'b0100;
            3'b110: ALUctr_ID = 4'b0110;
            3'b111: ALUctr_ID = 4'b0111;
            3'b001: ALUctr_ID = 4'b0001;
            3'b101: ALUctr_ID = func7_ID[5] ? 4'b1101 : 4'b0101;
          endcase
        end
        5'b01100: begin
          RegWr_ID   = 1'b1;
          ALUBsrc_ID = 2'b00;
          case (func3_ID)
            3'b000: ALUctr_ID = func7_ID[5] ? 4'b1000 : 4'b0000;
            3'b001: ALUctr_ID = 4'b0001;
            3'b010: ALUctr_ID = 4'b0010;
            3'b011: ALUctr_ID = 4'b1010;
            3'b100: ALUctr_ID = 4'b0100;
            3'b101: ALUctr_ID = func7_ID[5] ? 4'b1101 : 4'b0101;
            3'b110: ALUctr_ID = 4'b0110;
            3'b111: ALUctr_ID = 4'b0111;
          endcase
        end
        5'b11011: begin
          ExtOP_ID   = 3'b100;
          RegWr_ID   = 1'b1;
          Branch_ID  = 3'b001;
          ALUAsrc_ID = 1'b1;
          ALUBsrc_ID = 2'b10;
          ALUctr_ID  = 4'b0000;
        end
        5'b11001: begin
          ExtOP_ID   = 3'b000;
          RegWr_ID   = 1'b1;
          Branch_ID  = 3'b010;
          ALUAsrc_ID = 1'b1;
          ALUBsrc_ID = 2'b10;
          ALUctr_ID  = 4'b0000;
        end
        5'b11000: begin
          ExtOP_ID   = 3'b011;
          ALUAsrc_ID = 1'b0;
          ALUBsrc_ID = 2'b00;
          case (func3_ID)
            3'b000: begin
              Branch_ID = 3'b100;
              ALUctr_ID = 4'b0010;
            end
            3'b001: begin
              Branch_ID = 3'b101;
              ALUctr_ID = 4'b0010;
            end
            3'b100: begin
              Branch_ID = 3'b110;
              ALUctr_ID = 4'b0010;
            end
            3'b101: begin
              Branch_ID = 3'b111;
              ALUctr_ID = 4'b0010;
            end
            3'b110: begin
              Branch_ID = 3'b110;
              ALUctr_ID = 4'b1010;
            end
            3'b111: begin
              Branch_ID = 3'b111;
              ALUctr_ID = 4'b1010;
            end
          endcase
        end
        5'b00000: begin
          ExtOP_ID    = 3'b000;
          RegWr_ID    = 1'b1;
          MemtoReg_ID = 1'b1;
          MemOP_ID    = func3_ID;
          ALUBsrc_ID  = 2'b01;
          ALUctr_ID   = 4'b0000;
        end
        5'b01000: begin
          ExtOP_ID   = 3'b010;
          MemWr_ID   = 1'b1;
          MemOP_ID   = func3_ID;
          ALUBsrc_ID = 2'b01;
          ALUctr_ID  = 4'b0000;
        end
        default: ;
      endcase
    end
  end

  wire [31:0] rd1;
  wire [31:0] rd2;

  reg  [ 4:0] rd_WB;
  reg         RegWr_WB;
  reg         MemtoReg_WB;
  reg  [31:0] aluresult_WB;
  reg  [31:0] dmemdataout_WB;

  regfile myregfile (
      .clk(clock),
      .rs1(rs1_ID),
      .rs2(rs2_ID),
      .rd(rd_WB),
      .datain(dmemdataout_WB),
      .aluresult(aluresult_WB),
      .RegWr(RegWr_WB),
      .MemtoReg(MemtoReg_WB),
      .rd1(rd1),
      .rd2(rd2)
  );

  wire use_rs1 = (inst != 32'h0) && (op_ID[6:2] != 5'b01101) && (op_ID[6:2] != 5'b00101) && (op_ID[6:2] != 5'b11011);
  wire use_rs2 = (inst != 32'h0) && ((op_ID[6:2] == 5'b01100) || (op_ID[6:2] == 5'b01000) || (op_ID[6:2] == 5'b11000));

  reg [4:0] rd_EX;
  reg RegWr_EX;
  reg MemtoReg_EX;

  reg [31:0] PC_EX;
  reg [31:0] inst_EX;
  reg [31:0] val1_EX;
  reg [31:0] val2_EX;
  reg [31:0] imm_EX;
  reg [4:0] rs1_EX;
  reg [4:0] rs2_EX;

  reg ALUAsrc_EX;
  reg [1:0] ALUBsrc_EX;
  reg [3:0] ALUctr_EX;
  reg [2:0] Branch_EX;
  reg MemWr_EX;
  reg [2:0] MemOP_EX;

  always @(negedge clock) begin
    if (reset || jump_real || stall) begin
      PC_EX       <= 32'b0;
      inst_EX     <= 32'h00000013;
      val1_EX     <= 32'b0;
      val2_EX     <= 32'b0;
      imm_EX      <= 32'b0;
      rd_EX       <= 5'b0;
      rs1_EX      <= 5'b0;
      rs2_EX      <= 5'b0;
      ALUAsrc_EX  <= 1'b0;
      ALUBsrc_EX  <= 2'b00;
      ALUctr_EX   <= 4'b0000;
      Branch_EX   <= 3'b000;
      MemtoReg_EX <= 1'b0;
      MemWr_EX    <= 1'b0;
      MemOP_EX    <= 3'b000;
      RegWr_EX    <= 1'b0;
    end else begin
      PC_EX       <= PC_ID;
      inst_EX     <= inst;
      val1_EX     <= rd1;
      val2_EX     <= rd2;
      imm_EX      <= imm_ID;
      rd_EX       <= rd_ID;
      rs1_EX      <= rs1_ID;
      rs2_EX      <= rs2_ID;
      ALUAsrc_EX  <= ALUAsrc_ID;
      ALUBsrc_EX  <= ALUBsrc_ID;
      ALUctr_EX   <= ALUctr_ID;
      Branch_EX   <= Branch_ID;
      MemtoReg_EX <= MemtoReg_ID;
      MemWr_EX    <= MemWr_ID;
      MemOP_EX    <= MemOP_ID;
      RegWr_EX    <= RegWr_ID;
    end
  end

  reg [31:0] rs1_forwarded;
  reg [31:0] rs2_forwarded;

  reg [ 4:0] rd_MEM;
  reg        RegWr_MEM;
  reg        MemtoReg_MEM;
  reg [31:0] aluresult_MEM;

  always @(*) begin
    rs1_forwarded = val1_EX;
    if (RegWr_MEM && (rd_MEM != 5'b0) && (rd_MEM == rs1_EX)) begin
      if (!MemtoReg_MEM) begin
        rs1_forwarded = aluresult_MEM;
      end
    end else if (RegWr_WB && (rd_WB != 5'b0) && (rd_WB == rs1_EX)) begin
      rs1_forwarded = MemtoReg_WB ? dmemdataout_WB : aluresult_WB;
    end
  end

  always @(*) begin
    rs2_forwarded = val2_EX;
    if (RegWr_MEM && (rd_MEM != 5'b0) && (rd_MEM == rs2_EX)) begin
      if (!MemtoReg_MEM) begin
        rs2_forwarded = aluresult_MEM;
      end
    end else if (RegWr_WB && (rd_WB != 5'b0) && (rd_WB == rs2_EX)) begin
      rs2_forwarded = MemtoReg_WB ? dmemdataout_WB : aluresult_WB;
    end
  end

  wire [31:0] dataa_EX = (ALUAsrc_EX == 1'b0) ? rs1_forwarded : PC_EX;
  wire [31:0] datab_EX = (ALUBsrc_EX == 2'b00) ? rs2_forwarded : (ALUBsrc_EX == 2'b01) ? imm_EX : 32'd4;

  wire zero_EX;
  wire less_EX;
  wire [31:0] aluresult_EX;

  alu alu_inst (
      .dataa(dataa_EX),
      .datab(datab_EX),
      .ALUctr(ALUctr_EX),
      .less(less_EX),
      .zero(zero_EX),
      .aluresult(aluresult_EX)
  );

  always @(*) begin
    jump = 1'b0;
    jump_target = 32'b0;
    case (Branch_EX)
      3'b000:  ;
      3'b001: begin
        jump = 1'b1;
        jump_target = PC_EX + imm_EX;
      end
      3'b010: begin
        jump = 1'b1;
        jump_target = (rs1_forwarded + imm_EX) & 32'hfffffffe;
      end
      3'b100: begin
        if (zero_EX) begin
          jump = 1'b1;
          jump_target = PC_EX + imm_EX;
        end
      end
      3'b101: begin
        if (!zero_EX) begin
          jump = 1'b1;
          jump_target = PC_EX + imm_EX;
        end
      end
      3'b110: begin
        if (less_EX) begin
          jump = 1'b1;
          jump_target = PC_EX + imm_EX;
        end
      end
      3'b111: begin
        if (!less_EX) begin
          jump = 1'b1;
          jump_target = PC_EX + imm_EX;
        end
      end
      default: ;
    endcase
  end

  reg [31:0] PC_MEM;
  reg [31:0] val2_MEM;
  reg [ 2:0] MemOP_MEM;
  reg        MemWr_MEM;

  assign stall = RegWr_EX && MemtoReg_EX && (rd_EX != 5'b0) && ((use_rs1 && (rs1_ID == rd_EX)) || (use_rs2 && (rs2_ID == rd_EX)));

  always @(negedge clock) begin
    if (reset) begin
      PC_MEM        <= 32'b0;
      aluresult_MEM <= 32'b0;
      val2_MEM      <= 32'b0;
      rd_MEM        <= 5'b0;
      MemtoReg_MEM  <= 1'b0;
      MemWr_MEM     <= 1'b0;
      MemOP_MEM     <= 3'b000;
      RegWr_MEM     <= 1'b0;
    end else begin
      PC_MEM        <= PC_EX;
      aluresult_MEM <= aluresult_EX;
      val2_MEM      <= rs2_forwarded;
      rd_MEM        <= rd_EX;
      MemtoReg_MEM  <= MemtoReg_EX;
      MemWr_MEM     <= MemWr_EX;
      MemOP_MEM     <= MemOP_EX;
      RegWr_MEM     <= RegWr_EX;
    end
  end

  assign dmemaddr   = aluresult_MEM;
  assign dmemdatain = val2_MEM;
  assign dmemwe     = MemWr_MEM;
  assign dmemop     = MemOP_MEM;

  reg [31:0] PC_WB;

  always @(negedge clock) begin
    if (reset) begin
      PC_WB          <= 32'b0;
      aluresult_WB   <= 32'b0;
      dmemdataout_WB <= 32'b0;
      rd_WB          <= 5'b0;
      MemtoReg_WB    <= 1'b0;
      RegWr_WB       <= 1'b0;
    end else begin
      PC_WB          <= PC_MEM;
      aluresult_WB   <= aluresult_MEM;
      dmemdataout_WB <= dmemdataout;
      rd_WB          <= rd_MEM;
      MemtoReg_WB    <= MemtoReg_MEM;
      RegWr_WB       <= RegWr_MEM;
    end
  end

  assign dbgdata = PC_IF;

endmodule

module alu (
    input [31:0] dataa,
    input [31:0] datab,
    input [3:0] ALUctr,
    output less,
    output zero,
    output reg [31:0] aluresult
);

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

  wire [31:0] data = (MemtoReg == 1'b0) ? aluresult : datain;

  assign rd1 = (rs1 == 5'b0) ? 32'b0 : (RegWr && (rs1 == rd)) ? data : regs[rs1];
  assign rd2 = (rs2 == 5'b0) ? 32'b0 : (RegWr && (rs2 == rd)) ? data : regs[rs2];

  always @(posedge clk) begin
    if (RegWr && rd != 5'b0) begin
      regs[rd] <= data;
    end
  end

endmodule
