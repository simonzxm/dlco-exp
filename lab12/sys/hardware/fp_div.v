module fp_div (
    input             clk,
    input             reset,
    input             start,
    input      [31:0] a,
    input      [31:0] b,
    output reg [31:0] y,
    output reg        done
);

  wire        sa = a[31], sb = b[31];
  wire [ 7:0] ea = a[30:23], eb = b[30:23];
  wire [23:0] ma = {1'b1, a[22:0]}, mb = {1'b1, b[22:0]};
  wire        azero = (a[30:0] == 31'b0);

  wire [47:0] div_a = {ma, 24'b0};
  wire [47:0] div_b = {24'b0, mb};
  wire [47:0] q48;
  wire        ddone;

  intdiv #(48) u_div (
      .clk  (clk),
      .reset(reset),
      .start(start),
      .a    (div_a),
      .b    (div_b),
      .q    (q48),
      .r    (),
      .done (ddone)
  );

  wire norm = q48[24];
  wire [22:0] mant = norm ? q48[23:1] : q48[22:0];
  wire [9:0] enorm = {2'b0, ea} - {2'b0, eb} + 10'd127 - (norm ? 10'd0 : 10'd1);

  always @(posedge clk) begin
    if (reset) done <= 1'b0;
    else if (start) done <= 1'b0;
    else if (ddone && !done) begin
      y    <= azero ? 32'b0 : {sa ^ sb, enorm[7:0], mant};
      done <= 1'b1;
    end
  end

endmodule
