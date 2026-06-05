// CPU-driven VGA character buffer (replaces lab11 keyboard-driven cli.v).
// CPU writes ASCII bytes via memory map at 0x002xxxxx; VGA scan reads them out.
module vga_char (
    input         wclk,        // write clock (CPU dmem write clock)
    input         we,          // write enable (address-decoded for 0x002)
    input  [11:0] waddr,       // byte address within VGA space = (line<<7)+col
    input  [ 7:0] wdata,       // ASCII byte to store
    input  [ 9:0] h_addr,      // VGA scan column (0..639)
    input  [ 9:0] v_addr,      // VGA scan row (0..479)
    output [11:0] vga_data     // 12-bit RGB for current pixel
);

  reg [ 7:0] vram[4095:0];      // 30 rows x 128 stride = 3840 cells (rounded to 4096)
  reg [11:0] font_rom[4095:0];  // 256 chars x 16 rows, 8px wide font
  initial $readmemh("vga_font.txt", font_rom);

  // CPU write port: software uses single-byte stores (sb) to char*, so no sub-word logic.
  always @(posedge wclk)
    if (we) vram[waddr] <= wdata;

  // VGA read port: map scan position to the same (line<<7)+col cell the CPU wrote.
  wire [ 4:0] row = v_addr[8:4];          // character row 0..29
  wire [ 6:0] col = h_addr[9:3];          // character column 0..79
  wire [11:0] idx = {row, col};           // row*128 + col  (stride 128, matches software)
  wire [ 7:0] ch = vram[idx];
  wire [ 7:0] code = (ch < 8'h20) ? 8'h20 : ch;  // treat cleared/zero cells as blank space
  wire [11:0] font_row = font_rom[{code, v_addr[3:0]}];
  assign vga_data = font_row[h_addr[2:0]] ? 12'hFFF : 12'h000;  // white on black

endmodule
