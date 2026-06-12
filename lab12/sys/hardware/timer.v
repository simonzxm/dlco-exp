module timer (
    input             clk,
    input             reset,
    input             we,
    input      [31:0] wdata,
    output reg [31:0] time_reg
);

  reg [26:0] prescale;

  always @(posedge clk) begin
    if (reset) begin
      prescale <= 27'b0;
      time_reg <= 32'b0;
    end else if (we) begin
      prescale <= 27'b0;
      time_reg <= wdata;
    end else if (prescale == 27'd99_999_999) begin
      prescale <= 27'b0;
      time_reg <= time_reg + 32'd1;
    end else begin
      prescale <= prescale + 27'd1;
    end
  end

endmodule
