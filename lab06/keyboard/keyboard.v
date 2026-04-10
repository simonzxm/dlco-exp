module keyboard (
    input clk,
    input clrn,
    input ps2_clk,
    input ps2_data,
    output reg [7:0] key_count,
    output reg [7:0] cur_key,
    output [7:0] ascii_key,
    output reg left_shift,
    output reg left_ctrl,
    output reg left_alt
);

  wire [7:0] keydata;
  wire ready;
  wire overflow;
  reg nextdata_n;
  reg is_break;
  reg read;
  reg pressed;

  wire [7:0] raw_ascii;

  scancode_ram myram (
      .clk(clk),
      .addr(cur_key),
      .outdata(raw_ascii)
  );

  assign ascii_key = (left_shift && raw_ascii >= 8'h61 && raw_ascii <= 8'h7A) ? (raw_ascii - 8'h20) : raw_ascii;

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
      left_shift <= 0;
      left_ctrl <= 0;
      left_alt <= 0;
    end else begin
      if (read) begin
        nextdata_n <= 1;
        read <= 0;
      end else if (ready && !read) begin
        nextdata_n <= 0;
        read <= 1;
        if (keydata == 8'hF0) begin
          is_break <= 1;
        end else if (is_break) begin
          is_break <= 0;
          if (keydata == 8'h12) left_shift <= 0;
          else if (keydata == 8'h14) left_ctrl <= 0;
          else if (keydata == 8'h11) left_alt <= 0;
          else if (keydata == cur_key) begin
            cur_key <= 0;
            pressed <= 0;
          end
        end else begin
          if (keydata == 8'h12) left_shift <= 1;
          else if (keydata == 8'h14) left_ctrl <= 1;
          else if (keydata == 8'h11) left_alt <= 1;
          else if (!pressed) begin
            cur_key   <= keydata;
            key_count <= key_count + 1;
            pressed   <= 1;
          end
        end
      end
    end
  end

endmodule

