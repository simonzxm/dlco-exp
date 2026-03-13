module button (
    input  clk,
    input  btn,
    output btn_edge
);

  reg sync_0, sync_1;
  always @(posedge clk) begin
    sync_0 <= btn;
    sync_1 <= sync_0;
  end

  reg [19:0] count;
  reg btn_stable;

  always @(posedge clk) begin
    if (sync_1 != btn_stable) begin
      count <= count + 1;
      if (count == 20'd1_000_000) begin
        btn_stable <= sync_1;
        count <= 0;
      end
    end else begin
      count <= 0;
    end
  end

  reg btn_delayed;
  always @(posedge clk) begin
    btn_delayed <= btn_stable;
  end
  assign btn_edge = btn_stable & (~btn_delayed);

endmodule
