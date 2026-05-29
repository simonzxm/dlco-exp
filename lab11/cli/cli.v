module cli (
    input clk,
    input [7:0] ascii_key,
    input [7:0] key_count,
    input [9:0] h_addr,
    input [9:0] v_addr,
    output [11:0] vga_data
);

  reg [7:0] vram[2399:0];
  reg [11:0] font_rom[4095:0];
  initial $readmemh("vga_font.txt", font_rom);

  reg [6:0] cursor_x = 0;
  reg [4:0] cursor_y = 0;
  reg [7:0] prev_key_count = 0;
  reg offset = 0;

  always @(posedge clk) begin
    if (key_count != prev_key_count) begin
      prev_key_count <= key_count;
      if (ascii_key == 8'h0D) begin
        cursor_x <= 0;
        cursor_y <= (cursor_y == 29) ? 0 : cursor_y + 1;
        if (cursor_y == 29) offset <= 1;
      end else if ((ascii_key >= 8'h20) && (ascii_key <= 8'h7E)) begin
        vram[(cursor_y*80)+cursor_x] <= ascii_key;
        if (cursor_x == 79) begin
          cursor_x <= 0;
          cursor_y <= (cursor_y == 29) ? 0 : cursor_y + 1;
          if (cursor_y == 29) offset <= 1;
        end else begin
          cursor_x <= cursor_x + 1;
        end
      end
    end
  end

  wire [5:0] y_sum = v_addr[9:4] + cursor_y + 6'd1;
  wire [4:0] vram_row = offset ? ((y_sum >= 6'd30) ? (y_sum - 6'd30) : y_sum) : v_addr[9:4];

  wire is_blank = (vram_row == cursor_y && h_addr[9:3] >= cursor_x) || (!offset && vram_row > cursor_y);
  wire [7:0] char_code = is_blank ? 8'h20 : vram[(vram_row*80)+h_addr[9:3]];

  wire [11:0] font_row = font_rom[{char_code, v_addr[3:0]}];
  assign vga_data = font_row[h_addr[2:0]] ? 12'hFFF : 12'h000;

endmodule
