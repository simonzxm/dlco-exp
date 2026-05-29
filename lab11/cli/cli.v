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
  reg [4:0] y_offset = 0;

  always @(posedge clk) begin
    if (key_count != prev_key_count) begin
      prev_key_count <= key_count;
      if (ascii_key == 8'h0D) begin
        cursor_x <= 0;
        cursor_y <= (cursor_y == 29) ? 0 : cursor_y + 1;
        y_offset <= (cursor_y == 29) ? y_offset + 1 : y_offset;
      end else if (cursor_x == 79) begin
        cursor_x <= 0;
        cursor_y <= (cursor_y == 29) ? 0 : cursor_y + 1;
        y_offset <= (cursor_y == 29) ? y_offset + 1 : y_offset;
        vram[(cursor_y*80)+cursor_x] <= ascii_key;
      end else begin
        cursor_x <= cursor_x + 1;
        vram[(cursor_y*80)+cursor_x] <= ascii_key;
      end
    end
  end

  wire [11:0] font_row = font_rom[{vram[((v_addr[9:4]+y_offset)*80)+h_addr[9:3]], v_addr[3:0]}];
  assign vga_data = font_row[h_addr[2:0]] ? 12'hFFF : 12'h000;

endmodule
