module intdiv #(
    parameter W = 32
) (
    input              clk,
    input              reset,
    input              start,
    input      [W-1:0] a,
    input      [W-1:0] b,
    output reg [W-1:0] q,
    output reg [W-1:0] r,
    output reg         done
);

  reg  [  5:0] cnt;
  reg          run;
  reg  [W-1:0] N;
  reg  [W-1:0] R;
  reg  [W-1:0] D;

  wire [  W:0] Rsh = {R, N[W-1]};
  wire         ge = (Rsh >= {1'b0, D});
  wire [  W:0] Rsub = Rsh - {1'b0, D};

  always @(posedge clk) begin
    if (reset) begin
      run  <= 1'b0;
      done <= 1'b0;
    end else if (start) begin
      N    <= a;
      R    <= {W{1'b0}};
      D    <= b;
      cnt  <= 6'b0;
      run  <= 1'b1;
      done <= 1'b0;
    end else if (run) begin
      if (cnt == W - 1) begin
        q    <= {N[W-2:0], ge};
        r    <= ge ? Rsub[W-1:0] : Rsh[W-1:0];
        run  <= 1'b0;
        done <= 1'b1;
      end else begin
        N   <= {N[W-2:0], ge};
        R   <= ge ? Rsub[W-1:0] : Rsh[W-1:0];
        cnt <= cnt + 6'b1;
      end
    end
  end

endmodule
