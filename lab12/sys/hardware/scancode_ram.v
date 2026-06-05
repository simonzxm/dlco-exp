module scancode_ram (
    input  [7:0] addr,
    output [7:0] outdata
);
  reg [7:0] ascii_tab[255:0];
  initial begin
    $readmemh("ascii.txt", ascii_tab, 0, 255);
  end
  assign outdata = ascii_tab[addr];

endmodule
