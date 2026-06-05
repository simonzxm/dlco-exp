// CPU-driven VGA character buffer with a hardware start-row register for scrolling.
// CPU writes ASCII bytes (0x00200000 + (line<<7) + col) and a start-row register
// (0x00210000); VGA scan reads cells offset by start-row (mod 30) so software can
// scroll the screen just by bumping the register.
module vga_char (
    input         wclk,        // write clock (CPU dmem write clock)
    input         we,          // write enable (address-decoded for 0x002)
    input  [16:0] waddr,       // address within VGA space; bit[16] selects the register
    input  [ 7:0] wdata,       // ASCII byte / start-row value
    input  [ 9:0] h_addr,      // VGA scan column (0..639)
    input  [ 9:0] v_addr,      // VGA scan row (0..479)
    output [11:0] vga_data     // 12-bit RGB for current pixel
);

  reg [ 7:0] vram[4095:0];      // 30 rows x 128 stride = 3840 cells (rounded to 4096)
  reg [11:0] font_rom[4095:0];  // 256 chars x 16 rows, 8px wide font
  reg [ 4:0] start_row = 0;     // physical row shown at top of screen (scroll offset)
  initial $readmemh("vga_font.txt", font_rom);

  // CPU write port: waddr[16]=1 -> start-row register, else a character cell.
  // Software uses single-byte stores for cells and a word store for the register;
  // either way only the low byte matters here.
  always @(posedge wclk)
    if (we) begin
      if (waddr[16]) start_row <= wdata[4:0];
      else vram[waddr[11:0]] <= wdata;
    end

  // VGA read port: screen row -> physical row via start_row offset (mod 30),
  // then index the same (line<<7)+col cell the CPU wrote.
  wire [ 5:0] row_sum  = {1'b0, v_addr[8:4]} + {1'b0, start_row};
  wire [ 4:0] phys_row = (row_sum >= 6'd30) ? (row_sum - 6'd30) : row_sum[4:0];
  wire [ 6:0] col      = h_addr[9:3];
  wire [11:0] idx      = {phys_row, col};       // phys_row*128 + col
  wire [ 7:0] ch       = vram[idx];
  wire [ 7:0] code     = (ch < 8'h20) ? 8'h20 : ch;  // blank for cleared/zero cells
  wire [11:0] font_row = font_rom[{code, v_addr[3:0]}];
  assign vga_data = font_row[h_addr[2:0]] ? 12'hFFF : 12'h000;  // white on black

endmodule
