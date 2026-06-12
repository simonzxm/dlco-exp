module vga_char (
    input         wclk,
    input         we,
    input  [16:0] waddr,
    input  [ 7:0] wdata,
    input  [ 9:0] h_addr,
    input  [ 9:0] v_addr,
    output [11:0] vga_data
);

  reg [7:0] vram[4095:0];
  reg [11:0] font_rom[4095:0];
  reg [4:0] start_row = 0;
  reg [11:0] cursor_pos = 0;
  initial $readmemh("vga_font.txt", font_rom);

  always @(posedge wclk)
    if (we) begin
      if (waddr[16]) start_row <= wdata[4:0]; // scroll register
      else if (waddr[15]) cursor_pos <= waddr[11:0]; // cursor-position register
      else vram[waddr[11:0]] <= wdata;
    end

  wire [ 5:0] row_sum = {1'b0, v_addr[8:4]} + {1'b0, start_row};
  wire [ 4:0] phys_row = (row_sum >= 6'd30) ? (row_sum - 6'd30) : row_sum[4:0];
  wire [ 6:0] col = h_addr[9:3];
  wire [11:0] idx = {phys_row, col};
  wire [ 7:0] ch = vram[idx];
  wire [ 7:0] code = (ch < 8'h20) ? 8'h20 : ch;
  wire [11:0] font_row = font_rom[{code, v_addr[3:0]}];
  assign vga_data = (font_row[h_addr[2:0]] ^ (idx == cursor_pos)) ? 12'hFFF : 12'h000;

endmodule
