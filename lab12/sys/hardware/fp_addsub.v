module fp_addsub (
    input      [31:0] a,
    input      [31:0] b_in,
    input             sub,
    output reg [31:0] y
);

  wire [31:0] b = {b_in[31] ^ sub, b_in[30:0]};
  wire [7:0] ea = a[30:23], eb = b[30:23];
  wire [23:0] ma = {1'b1, a[22:0]}, mb = {1'b1, b[22:0]};
  wire azero = (a[30:0] == 31'b0), bzero = (b[30:0] == 31'b0);

  wire agt = (ea > eb) || ((ea == eb) && (a[22:0] >= b[22:0]));
  wire [7:0] eh = agt ? ea : eb, el = agt ? eb : ea;
  wire [23:0] mh = agt ? ma : mb, ml = agt ? mb : ma;
  wire shi = agt ? a[31] : b[31];
  wire slo = agt ? b[31] : a[31];
  wire [7:0] diff = eh - el;

  reg [24:0] mls;
  reg [24:0] msum;
  reg [24:0] mn;
  reg [7:0] eo;
  integer i;

  always @(*) begin
    if (azero) y = b;
    else if (bzero) y = a;
    else begin
      mls  = (diff >= 8'd25) ? 25'b0 : ({1'b0, ml} >> diff);
      msum = (shi == slo) ? ({1'b0, mh} + mls) : ({1'b0, mh} - mls);
      eo   = eh;
      mn   = msum;
      if (msum == 25'b0) y = 32'b0;
      else begin
        if (mn[24]) begin
          mn = mn >> 1;
          eo = eo + 8'b1;
        end else begin
          for (i = 0; i < 24; i = i + 1)
          if (mn[23] == 1'b0) begin
            mn = mn << 1;
            eo = eo - 8'b1;
          end
        end
        y = {shi, eo, mn[22:0]};
      end
    end
  end

endmodule
