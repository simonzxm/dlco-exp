// 8-digit multiplexed 7-segment display driver
// Scans all 8 digits using CLK100MHZ
// data[31:0] = {digit7[31:28], digit6[27:24], ..., digit1[7:4], digit0[3:0]}
module display8 (
    input         clk,        // CLK100MHZ
    input  [31:0] data,       // 8 hex nibbles
    output reg [7:0] an,
    output [6:0]  seg
);

  reg [16:0] counter;
  wire [2:0] current = counter[16:14];
  reg  [3:0] hex;

  always @(posedge clk)
    counter <= counter + 1;

  // Anode: only one active at a time
  always @(*) begin
    an = 8'b11111111;
    an[current] = 1'b0;
  end

  // Nibble mux
  always @(*) begin
    case (current)
      3'd0: hex = data[3:0];
      3'd1: hex = data[7:4];
      3'd2: hex = data[11:8];
      3'd3: hex = data[15:12];
      3'd4: hex = data[19:16];
      3'd5: hex = data[23:20];
      3'd6: hex = data[27:24];
      3'd7: hex = data[31:28];
      default: hex = 4'd0;
    endcase
  end

  hex7seg decoder (
      .hex(hex),
      .seg(seg)
  );

endmodule
