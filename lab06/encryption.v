module encryption (
    input [63:0] seed,
    input clk,
    input load,
    input [7:0] datain,
    output reg ready,
    output [7:0] dataout
);

  //add your code here
  wire [63:0] key;
  reg  [ 2:0] timer;
  lfsr lfsr_inst (
      .seed(seed),
      .clk (clk),
      .load(load),
      .dout(key)
  );

  always @(posedge clk) begin
    if (load) begin
      timer <= 0;
      ready <= 0;
    end else begin
      if (timer == 3'd5) begin
        timer <= 0;
        ready <= 1;
      end else begin
        timer <= timer + 1;
        ready <= 0;
      end
    end
  end

  assign dataout = {datain[7:6], (datain[5:0] ^ key[63:58])};

endmodule

module lfsr (
    input [63:0] seed,
    input clk,
    input load,
    output reg [63:0] dout
);

  always @(posedge clk) begin
    if (load) dout <= seed;
    else dout <= {dout[4] ^ dout[3] ^ dout[1] ^ dout[0], dout[63:1]};
  end

endmodule
