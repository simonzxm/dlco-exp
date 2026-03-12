module exp2 (
    input [7:0] X,
    input en,
    output reg valid,
    output [6:0] F
);

  //add your code here
  reg [3:0] value;
  always @(X or en) begin
    if (en) begin
      casez (X)
        8'b1???????: begin
          value = 4'd7;
          valid = 1'b1;
        end
        8'b01??????: begin
          value = 4'd6;
          valid = 1'b1;
        end
        8'b001?????: begin
          value = 4'd5;
          valid = 1'b1;
        end
        8'b0001????: begin
          value = 4'd4;
          valid = 1'b1;
        end
        8'b00001???: begin
          value = 4'd3;
          valid = 1'b1;
        end
        8'b000001??: begin
          value = 4'd2;
          valid = 1'b1;
        end
        8'b0000001?: begin
          value = 4'd1;
          valid = 1'b1;
        end
        8'b00000001: begin
          value = 4'd0;
          valid = 1'b1;
        end
        default: begin
          value = 4'd0;
          valid = 1'b0;
        end
      endcase
    end else begin
      value = 4'd0;
      valid = 1'b0;
    end
  end

  wire [6:0] F_temp;
  bcd7seg display (
      .b(value),
      .h(F_temp)
  );
  assign F = (valid) ? F_temp : 7'b1111111;

endmodule


module bcd7seg (
    input [3:0] b,
    output reg [6:0] h
);

  //add your code here
  always @(b)
    case (b)
      4'd0: h = 7'b1000000;
      4'd1: h = 7'b1111001;
      4'd2: h = 7'b0100100;
      4'd3: h = 7'b0110000;
      4'd4: h = 7'b0011001;
      4'd5: h = 7'b0010010;
      4'd6: h = 7'b0000010;
      4'd7: h = 7'b1111000;
      default: h = 7'b1111111;
    endcase

endmodule
