module top (
    input CLK100MHZ,
    input CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,
    output [6:0] SEG,
    output [7:0] AN,
    output [2:0] LED
);

    wire [7:0] key_count;
    wire [7:0] cur_key;
    wire [7:0] ascii_key;

    wire left_shift, left_ctrl, left_alt;

    keyboard key_inst (
        .clk(CLK100MHZ),
        .clrn(CPU_RESETN),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .key_count(key_count),
        .cur_key(cur_key),
        .ascii_key(ascii_key),
        .left_shift(LED[0]),
        .left_ctrl(LED[1]),
        .left_alt(LED[2])
    );

    assign LED = {left_alt, left_ctrl, left_shift};

    wire [7:0] display_en = {2'b11, 2'b00, {4{cur_key != 8'h00}}};
    wire [31:0] display_data = {key_count, 8'h00, ascii_key, cur_key};

    display disp_inst (
        .clk(CLK100MHZ),
        .data(display_data),
        .en(display_en),
        .an(AN),
        .seg(SEG)
    );

endmodule