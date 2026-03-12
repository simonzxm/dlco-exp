module display (
    input clk,
    input [31:0] data,
    output reg [7:0] an,
    output [6:0] seg
);

  reg [16:0] counter;
  reg [ 2:0] current;
  reg [ 3:0] bcd;

  always @(posedge clk) begin
    counter <= counter + 1;
    current <= counter[16:14];
  end

  always @(*) begin
    an = 8'b11111111;
    an[current] = 1'b0;
  end

  always @(*) begin
    case (current)
      3'd0: bcd = data[3:0];
      3'd1: bcd = data[7:4];
      3'd2: bcd = data[11:8];
      3'd3: bcd = data[15:12];
      3'd4: bcd = data[19:16];
      3'd5: bcd = data[23:20];
      3'd6: bcd = data[27:24];
      3'd7: bcd = data[31:28];
      default: bcd = 4'd0;
    endcase
  end

  bcd7seg decoder (
      .bcd(bcd),
      .seg(seg)
  );

endmodule
