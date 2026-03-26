module clz (
    input [31:0] in,
    output [4:0] out,
    output zero
);

  //add your code here
  wire [4:0] count_high, count_low;
  wire high_zero, low_zero;

  assign high_zero = (in[31:16] == 16'b0);

  assign count_high = in[31] ? 5'd0  :
                      in[30] ? 5'd1  :
                      in[29] ? 5'd2  :
                      in[28] ? 5'd3  :
                      in[27] ? 5'd4  :
                      in[26] ? 5'd5  :
                      in[25] ? 5'd6  :
                      in[24] ? 5'd7  :
                      in[23] ? 5'd8  :
                      in[22] ? 5'd9  :
                      in[21] ? 5'd10 :
                      in[20] ? 5'd11 :
                      in[19] ? 5'd12 :
                      in[18] ? 5'd13 :
                      in[17] ? 5'd14 :
                      in[16] ? 5'd15 : 5'd16;

  assign count_low =  in[15] ? 5'd0  :
                      in[14] ? 5'd1  :
                      in[13] ? 5'd2  :
                      in[12] ? 5'd3  :
                      in[11] ? 5'd4  :
                      in[10] ? 5'd5  :
                      in[9]  ? 5'd6  :
                      in[8]  ? 5'd7  :
                      in[7]  ? 5'd8  :
                      in[6]  ? 5'd9  :
                      in[5]  ? 5'd10 :
                      in[4]  ? 5'd11 :
                      in[3]  ? 5'd12 :
                      in[2]  ? 5'd13 :
                      in[1]  ? 5'd14 : 5'd15;

  assign out = high_zero ? (5'd16 + count_low) : count_high;
  assign zero = (in == 32'b0);

endmodule
