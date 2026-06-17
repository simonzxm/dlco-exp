module fp_cvt (
    input      [31:0] a,
    input             op,  // 0: itof (signed), 1: ftoi (truncate)
    output reg [31:0] y
);

  // itof
  wire isign = a[31];
  wire [31:0] mag = isign ? (~a + 32'b1) : a;
  reg [31:0] m;
  reg [7:0] e;
  integer i;

  // ftoi
  wire fsign = a[31];
  wire [7:0] fe = a[30:23];
  wire [31:0] fm = {8'b0, 1'b1, a[22:0]};
  wire [7:0] sh = fe - 8'd127;
  reg [31:0] fv;

  always @(*) begin
    if (op == 1'b0) begin
      if (a == 32'b0) y = 32'b0;
      else begin
        m = mag;
        e = 8'd127 + 8'd31;
        for (i = 0; i < 32; i = i + 1)
        if (m[31] == 1'b0) begin
          m = m << 1;
          e = e - 8'b1;
        end
        y = {isign, e, m[30:8]};
      end
    end else begin
      if (fe < 8'd127) fv = 32'b0;
      else if (sh <= 8'd23) fv = fm >> (8'd23 - sh);
      else fv = fm << (sh - 8'd23);
      y = fsign ? (~fv + 32'b1) : fv;
    end
  end

endmodule
