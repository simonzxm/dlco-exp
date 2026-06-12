module keyboard (
    input clk,
    input clrn,
    input ps2_clk,
    input ps2_data,
    output reg [7:0] key_count,
    output reg [7:0] cur_key,
    output [7:0] ascii_key,
    output shift,
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
  reg left_shift;
  reg right_shift;

  wire [7:0] raw_ascii;

  scancode_ram myram (
      .addr(cur_key),
      .outdata(raw_ascii)
  );

  reg [7:0] shifted_ascii;
  always @(*) begin
    if (left_shift | right_shift) begin
      if (raw_ascii >= 8'h61 && raw_ascii <= 8'h7A) begin
        shifted_ascii = raw_ascii - 8'h20;
      end else begin
        case (raw_ascii)
          8'h31:   shifted_ascii = 8'h21;  // 1 -> !
          8'h32:   shifted_ascii = 8'h40;  // 2 -> @
          8'h33:   shifted_ascii = 8'h23;  // 3 -> #
          8'h34:   shifted_ascii = 8'h24;  // 4 -> $
          8'h35:   shifted_ascii = 8'h25;  // 5 -> %
          8'h36:   shifted_ascii = 8'h5E;  // 6 -> ^
          8'h37:   shifted_ascii = 8'h26;  // 7 -> &
          8'h38:   shifted_ascii = 8'h2A;  // 8 -> *
          8'h39:   shifted_ascii = 8'h28;  // 9 -> (
          8'h30:   shifted_ascii = 8'h29;  // 0 -> )
          8'h2D:   shifted_ascii = 8'h5F;  // - -> _
          8'h3D:   shifted_ascii = 8'h2B;  // = -> +
          8'h5B:   shifted_ascii = 8'h7B;  // [ -> {
          8'h5D:   shifted_ascii = 8'h7D;  // ] -> }
          8'h5C:   shifted_ascii = 8'h7C;  // \ -> |
          8'h3B:   shifted_ascii = 8'h3A;  // ; -> :
          8'h27:   shifted_ascii = 8'h22;  // ' -> "
          8'h2C:   shifted_ascii = 8'h3C;  // , -> <
          8'h2E:   shifted_ascii = 8'h3E;  // . -> >
          8'h2F:   shifted_ascii = 8'h3F;  // / -> ?
          8'h60:   shifted_ascii = 8'h7E;  // ` -> ~
          default: shifted_ascii = raw_ascii;
        endcase
      end
    end else begin
      shifted_ascii = raw_ascii;
    end
  end

  assign ascii_key = shifted_ascii;
  assign shift = left_shift | right_shift;

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
      right_shift <= 0;
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
        end else if (keydata == 8'hE0) begin
          // extended-key prefix (arrows / home / end / delete):
          // ignore it, the real scancode follows in the next byte
        end else if (is_break) begin
          is_break <= 0;
          if (keydata == 8'h12) left_shift <= 0;
          else if (keydata == 8'h59) right_shift <= 0;
          else if (keydata == 8'h14) left_ctrl <= 0;
          else if (keydata == 8'h11) left_alt <= 0;
          else if (keydata == cur_key) begin
            cur_key <= 0;
            pressed <= 0;
          end
        end else begin
          if (keydata == 8'h12) left_shift <= 1;
          else if (keydata == 8'h59) right_shift <= 1;
          else if (keydata == 8'h14) left_ctrl <= 1;
          else if (keydata == 8'h11) left_alt <= 1;
          else begin
            if (!pressed) begin
              cur_key   <= keydata;
              key_count <= key_count + 1;
              pressed   <= 1;
            end else if (keydata == cur_key) begin
              key_count <= key_count + 1;
            end else begin
              cur_key   <= keydata;
              key_count <= key_count + 1;
              pressed   <= 1;
            end
          end
        end
      end
    end
  end

endmodule
