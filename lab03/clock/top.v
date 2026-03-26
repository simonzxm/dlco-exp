module top (
    input CLK100MHZ,
    input BTNC,
    input BTNU,
    input BTND,
    input BTNL,
    input BTNR,
    input ALARM_SW,
    output [6:0] SEG,
    output [7:0] AN,
    output ALARM_LED,
    output ALARM_EN_LED
);

  wire tick_10ms, tick_1s;
  tick_gen #(
      .MAX_COUNT(32'd999999)
  ) tick_gen_10ms (
      .clk (CLK100MHZ),
      .tick(tick_10ms)
  );
  tick_gen #(
      .MAX_COUNT(32'd99999999)
  ) tick_gen_1s (
      .clk (CLK100MHZ),
      .tick(tick_1s)
  );

  wire btn_mode, btn_up, btn_down, btn_left, btn_right;
  button btn_c (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNC),
      .btn_edge(btn_mode)
  );
  button btn_u (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNU),
      .btn_edge(btn_up)
  );
  button btn_d (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTND),
      .btn_edge(btn_down)
  );
  button btn_l (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNL),
      .btn_edge(btn_left)
  );
  button btn_r (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .btn(BTNR),
      .btn_edge(btn_right)
  );

  // 0: Clock, 1: Set Time, 2: Set Alarm, 3: Stopwatch
  reg [1:0] mode = 0;
  always @(posedge CLK100MHZ) begin
    if (btn_mode) mode <= mode + 1;
  end

  // 0: hour, 1: min, 2: sec
  reg [1:0] adj_field = 0;
  always @(posedge CLK100MHZ) begin
    if (btn_mode) begin
      adj_field <= 0;
    end else if (mode == 2'd1 || mode == 2'd2) begin
      if (btn_left) begin
        if (adj_field == 0) adj_field <= (mode == 2'd1) ? 2'd2 : 2'd1;
        else adj_field <= adj_field - 1;
      end
      if (btn_right) begin
        if (adj_field == ((mode == 2'd1) ? 2'd2 : 2'd1)) adj_field <= 0;
        else adj_field <= adj_field + 1;
      end
    end
  end

  // Clock Core
  wire [3:0] clk_hour_tens, clk_hour_ones;
  wire [3:0] clk_min_tens, clk_min_ones;
  wire [3:0] clk_sec_tens, clk_sec_ones;
  clock_core clock_inst (
      .clk(CLK100MHZ),
      .tick_1s(tick_1s),
      .setting(mode == 2'd1),
      .adj_field(adj_field),
      .adj_up(btn_up),
      .adj_down(btn_down),
      .hour_tens(clk_hour_tens),
      .hour_ones(clk_hour_ones),
      .min_tens(clk_min_tens),
      .min_ones(clk_min_ones),
      .sec_tens(clk_sec_tens),
      .sec_ones(clk_sec_ones)
  );

  // Alarm
  wire [3:0] alm_hour_tens, alm_hour_ones;
  wire [3:0] alm_min_tens, alm_min_ones;
  alarm alarm_inst (
      .clk(CLK100MHZ),
      .tick_1s(tick_1s),
      .setting(mode == 2'd2),
      .adj_field(adj_field),
      .adj_up(btn_up),
      .adj_down(btn_down),
      .alarm_on(ALARM_SW),
      .cur_hour_tens(clk_hour_tens),
      .cur_hour_ones(clk_hour_ones),
      .cur_min_tens(clk_min_tens),
      .cur_min_ones(clk_min_ones),
      .alarm_hour_tens(alm_hour_tens),
      .alarm_hour_ones(alm_hour_ones),
      .alarm_min_tens(alm_min_tens),
      .alarm_min_ones(alm_min_ones),
      .led(ALARM_LED)
  );

  // Stopwatch
  wire [3:0] sw_min_tens, sw_min_ones;
  wire [3:0] sw_sec_tens, sw_sec_ones;
  wire [3:0] sw_csec_tens, sw_csec_ones;
  stopwatch sw_inst (
      .clk(CLK100MHZ),
      .tick_10ms(tick_10ms),
      .start_pause(btn_up & (mode == 2'd3)),
      .reset(btn_down & (mode == 2'd3)),
      .min_tens(sw_min_tens),
      .min_ones(sw_min_ones),
      .sec_tens(sw_sec_tens),
      .sec_ones(sw_sec_ones),
      .csec_tens(sw_csec_tens),
      .csec_ones(sw_csec_ones)
  );

  // Display Mux
  reg [31:0] display_data;
  always @(*) begin
    case (mode)
      2'd0:
      display_data = {
        clk_hour_tens,
        clk_hour_ones,
        clk_min_tens,
        clk_min_ones,
        clk_sec_tens,
        clk_sec_ones,
        4'hF,
        4'hF
      };
      2'd1:
      display_data = {
        clk_hour_tens,
        clk_hour_ones,
        clk_min_tens,
        clk_min_ones,
        clk_sec_tens,
        clk_sec_ones,
        4'hF,
        4'hF
      };
      2'd2:
      display_data = {
        alm_hour_tens, alm_hour_ones, alm_min_tens, alm_min_ones, 4'hF, 4'hF, 4'hF, 4'hF
      };
      2'd3:
      display_data = {
        4'hF, 4'hF, sw_min_tens, sw_min_ones, sw_sec_tens, sw_sec_ones, sw_csec_tens, sw_csec_ones
      };
      default: display_data = 32'd0;
    endcase
  end

  // Display
  wire [7:0] an_raw;
  display disp_inst (
      .clk (CLK100MHZ),
      .data(display_data),
      .an  (an_raw),
      .seg (SEG)
  );

  // Blink
  reg [24:0] blink_cnt = 0;
  always @(posedge CLK100MHZ) blink_cnt <= blink_cnt + 1;
  wire blink = blink_cnt[24];
  reg [7:0] blink_mask;
  always @(*) begin
    blink_mask = 8'b00000000;
    if ((mode == 2'd1 || mode == 2'd2) && blink) begin
      case (adj_field)
        2'd0:    blink_mask = 8'b11000000;
        2'd1:    blink_mask = 8'b00110000;
        2'd2:    blink_mask = 8'b00001100;
        default: blink_mask = 8'b00000000;
      endcase
    end
  end
  assign AN = an_raw | blink_mask;
  assign ALARM_EN_LED = ALARM_SW;

endmodule
