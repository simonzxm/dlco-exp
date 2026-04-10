module display (
    input             clk,
    input      [31:0] data,
    input      [ 7:0] en,
    output reg [ 7:0] an,
    output     [ 6:0] seg
);

  reg  [16:0] counter;
  wire [ 2:0] current = counter[16:14];
  reg  [ 3:0] hex;

  always @(posedge clk) counter <= counter + 1;

  always @(*) begin
    an = 8'b11111111;
    an[current] = 1'b0;
  end

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
      .seg(seg),
      .en (en[current])
  );

endmodule
