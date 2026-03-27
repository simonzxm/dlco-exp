module shiftreg (
    input [7:0] din,
    input clk,
    input [2:0] func,
    input lin,
    output reg [7:0] dout
);

  //add your code here
  always @(posedge clk) begin
    case (func)
      3'b000:  dout <= 8'd0;
      3'b001:  dout <= din;
      3'b010:  dout <= {1'b0, dout[7:1]};
      3'b011:  dout <= {dout[6:0], 1'b0};
      3'b100:  dout <= {dout[7], dout[7:1]};
      3'b101:  dout <= {lin, dout[7:1]};
      3'b110:  dout <= {dout[0], dout[7:1]};
      3'b111:  dout <= {dout[6:0], dout[7]};
      default: dout <= dout;
    endcase
  end

endmodule
