module keyboard (
    input clk,
    input clrn,
    input ps2_clk,
    input ps2_data,
    output reg [7:0] key_count,
    output reg [7:0] cur_key,
    output [7:0] ascii_key
);

  wire [7:0] keydata;
  wire ready;
  wire overflow;
  reg nextdata_n;
  reg is_break;
  reg read;
  reg pressed;

  scancode_ram myram (
      .clk(clk),
      .addr(cur_key),
      .outdata(ascii_key)
  );

  ps2_keyboard mykey (
      .clk(clk),
      .clrn(clrn),
      .ps2_clk(ps2_clk),
      .ps2_data(ps2_data),
      .data(keydata),
      .ready(ready),
      .nextdata_n(nextdata_n),
      .overflow(overflow)
  );

  always @(posedge clk) begin
    if (clrn == 0) begin
      key_count <= 0;
      cur_key <= 0;
      nextdata_n <= 1;
      is_break <= 0;
      read <= 0;
      pressed <= 0;
    end else begin
      if (read) begin
        nextdata_n <= 1;
        read <= 0;
      end else if (ready && !read) begin
        nextdata_n <= 0;
        read <= 1;
        if (keydata == 8'hF0) begin
          is_break <= 1;
          pressed  <= 0;
        end else if (is_break) begin
          is_break <= 0;
          cur_key  <= 0;
          pressed  <= 0;
        end else if (!pressed) begin
          cur_key   <= keydata;
          key_count <= key_count + 1;
          pressed   <= 1;
        end
      end
    end
  end

endmodule