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


  // ======== Tick Generators ========
  wire tick_10ms;
  wire tick_1s;

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

  // ======== Button Debounce ========
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

  // ======== Mode State Machine ========
  // 0: Clock, 1: Set Time, 2: Set Alarm, 3: Stopwatch
  reg [1:0] mode = 0;

  always @(posedge CLK100MHZ) begin
    if (btn_mode) mode <= mode + 1;
  end

  // ======== Field Select (for setting modes) ========
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

  // ======== Clock Core ========
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

  // ======== Alarm ========
  wire [3:0] alm_hour_tens, alm_hour_ones;
  wire [3:0] alm_min_tens, alm_min_ones;
  wire alarm_led;

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
      .led(alarm_led)
  );

  // ======== Stopwatch ========
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

  // ======== Display Mux ========
  reg [31:0] disp_data;

  // Blink counter for setting mode (selected digits blink)
  reg [24:0] blink_cnt = 0;
  always @(posedge CLK100MHZ) blink_cnt <= blink_cnt + 1;
  wire blink = blink_cnt[24];  // ~3Hz blink

  always @(*) begin
    case (mode)
      2'd0: begin  // Normal clock: HH.MM.SS on AN[7:2], AN[1:0] off
        disp_data = {
          clk_hour_tens,
          clk_hour_ones,
          clk_min_tens,
          clk_min_ones,
          clk_sec_tens,
          clk_sec_ones,
          4'hF,
          4'hF
        };
      end
      2'd1: begin  // Set time: same layout, selected field blinks
        disp_data = {
          clk_hour_tens,
          clk_hour_ones,
          clk_min_tens,
          clk_min_ones,
          clk_sec_tens,
          clk_sec_ones,
          4'hF,
          4'hF
        };
      end
      2'd2: begin  // Set alarm: HH.MM on AN[7:4], SS=blank, AN[1:0] off
        disp_data = {
          alm_hour_tens, alm_hour_ones, alm_min_tens, alm_min_ones, 4'hF, 4'hF, 4'hF, 4'hF
        };
      end
      2'd3: begin  // Stopwatch: MM.SS.CC on AN[5:0], AN[7:6] off
        disp_data = {
          4'hF, 4'hF, sw_min_tens, sw_min_ones, sw_sec_tens, sw_sec_ones, sw_csec_tens, sw_csec_ones
        };
      end
    endcase
  end

  // ======== Display with blink masking ========
  wire [7:0] an_raw;
  wire [6:0] seg_raw;

  display disp_inst (
      .clk (CLK100MHZ),
      .data(disp_data),
      .an  (an_raw),
      .seg (seg_raw)
  );

  // Blink mask: in setting modes, blank the selected field's digits
  reg [7:0] blink_mask;
  always @(*) begin
    blink_mask = 8'b00000000;
    if ((mode == 2'd1 || mode == 2'd2) && blink) begin
      case (adj_field)
        2'd0: blink_mask = 8'b11000000;  // hour digits AN[7:6]
        2'd1: blink_mask = 8'b00110000;  // min digits AN[5:4]
        2'd2: blink_mask = 8'b00001100;  // sec digits AN[3:2]
        default: blink_mask = 8'b00000000;
      endcase
    end
  end

  assign AN  = an_raw | blink_mask;  // mask=1 turns off digit (active low)
  assign SEG = seg_raw;

  // ======== LED Output ========
  assign ALARM_LED    = alarm_led;
  assign ALARM_EN_LED = ALARM_SW;

endmodule
