module top (
    input        CLK100MHZ,
    input  [7:0] SW,
    input        CPU_RESETN,
    output [6:0] SEG,
    output [7:0] AN
);

  wire reset = ~CPU_RESETN;

  wire [31:0] imemaddr, imemdataout;
  wire imemclk;
  wire [31:0] dmemaddr, dmemdataout, dmemdatain;
  wire dmemrdclk, dmemwrclk, dmemwe;
  wire [2:0] dmemop;
  wire [31:0] dbgdata;

  reg halted;
  always @(posedge CLK100MHZ) begin
    if (reset) halted <= 0;
    else if (!halted && imemdataout == 32'hdead10cc) halted <= 1;
  end

  wire [31:0] addi_sw = {4'b0, SW, 5'b00000, 3'b000, 5'b01010, 7'b0010011};

  rv32is cpu (
      .clock(CLK100MHZ),
      .reset(reset),
      .imemaddr(imemaddr),
      .imemdataout(halted ? 32'h00000013 : (imemdataout == 32'h00A00513) ? addi_sw : imemdataout),
      .imemclk(imemclk),
      .dmemaddr(dmemaddr),
      .dmemdataout(dmemdataout),
      .dmemdatain(dmemdatain),
      .dmemrdclk(dmemrdclk),
      .dmemwrclk(dmemwrclk),
      .dmemop(dmemop),
      .dmemwe(dmemwe),
      .dbgdata(dbgdata)
  );

  blk_mem_gen_1 imem (
      .clka (imemclk),
      .addra(imemaddr[9:2]),
      .douta(imemdataout)
  );

  dmem dmem_inst (
      .addr(dmemaddr[16:0]),
      .dataout(dmemdataout),
      .datain(dmemdatain),
      .wrclk(dmemwrclk),
      .rdclk(dmemrdclk),
      .memop(dmemop),
      .we(dmemwe)
  );

  display disp_inst (
      .clk (CLK100MHZ),
      .data(dbgdata),
      .an  (AN),
      .seg (SEG)
  );

endmodule
