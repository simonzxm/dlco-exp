module regfile16x8 (
    input        clk,
    input        we,       // write enable
    input  [3:0] addr,     // read/write address
    input  [7:0] wdata,    // write data
    output [7:0] rdata     // read data (async)
);

  reg [7:0] ram [0:15];

  // Initialize from file
  initial begin
    $readmemh("mem1.txt", ram, 0, 15);
  end

  // Asynchronous read
  assign rdata = ram[addr];

  // Synchronous write
  always @(posedge clk) begin
    if (we)
      ram[addr] <= wdata;
  end

endmodule
