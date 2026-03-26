module alarm (
    input wire clk,
    input wire tick_1s,
    input wire setting,
    input wire [1:0] adj_field,  // 0=hour, 1=min
    input wire adj_up,
    input wire adj_down,
    input wire alarm_on,
    input wire [3:0] cur_hour_tens,
    input wire [3:0] cur_hour_ones,
    input wire [3:0] cur_min_tens,
    input wire [3:0] cur_min_ones,
    output reg [3:0] alarm_hour_tens,
    output reg [3:0] alarm_hour_ones,
    output reg [3:0] alarm_min_tens,
    output reg [3:0] alarm_min_ones,
    output reg led
);

  initial begin
    alarm_hour_tens = 0;
    alarm_hour_ones = 0;
    alarm_min_tens  = 0;
    alarm_min_ones  = 0;
  end

  wire hour_carry = (alarm_hour_tens == 2) && (alarm_hour_ones == 3);
  wire min_carry = (alarm_min_tens == 5) && (alarm_min_ones == 9);

  // Alarm time adjustment - hour
  always @(posedge clk) begin
    if (setting && adj_field == 2'd0) begin
      if (adj_up) begin
        if (hour_carry) begin
          alarm_hour_tens <= 0;
          alarm_hour_ones <= 0;
        end else if (alarm_hour_ones == 9) begin
          alarm_hour_ones <= 0;
          alarm_hour_tens <= alarm_hour_tens + 1;
        end else begin
          alarm_hour_ones <= alarm_hour_ones + 1;
        end
      end
      if (adj_down) begin
        if (alarm_hour_tens == 0 && alarm_hour_ones == 0) begin
          alarm_hour_tens <= 2;
          alarm_hour_ones <= 3;
        end else if (alarm_hour_ones == 0) begin
          alarm_hour_ones <= 9;
          alarm_hour_tens <= alarm_hour_tens - 1;
        end else begin
          alarm_hour_ones <= alarm_hour_ones - 1;
        end
      end
    end
  end

  // Alarm time adjustment - minute
  always @(posedge clk) begin
    if (setting && adj_field == 2'd1) begin
      if (adj_up) begin
        if (min_carry) begin
          alarm_min_tens <= 0;
          alarm_min_ones <= 0;
        end else if (alarm_min_ones == 9) begin
          alarm_min_ones <= 0;
          alarm_min_tens <= alarm_min_tens + 1;
        end else begin
          alarm_min_ones <= alarm_min_ones + 1;
        end
      end
      if (adj_down) begin
        if (alarm_min_tens == 0 && alarm_min_ones == 0) begin
          alarm_min_tens <= 5;
          alarm_min_ones <= 9;
        end else if (alarm_min_ones == 0) begin
          alarm_min_ones <= 9;
          alarm_min_tens <= alarm_min_tens - 1;
        end else begin
          alarm_min_ones <= alarm_min_ones - 1;
        end
      end
    end
  end

  // Alarm match detection + LED blink
  wire match = alarm_on &&
               (cur_hour_tens == alarm_hour_tens) &&
               (cur_hour_ones == alarm_hour_ones) &&
               (cur_min_tens  == alarm_min_tens) &&
               (cur_min_ones  == alarm_min_ones);

  reg blink = 0;
  always @(posedge clk) begin
    if (match) begin
      if (tick_1s) blink <= ~blink;
    end else begin
      blink <= 0;
    end
    led <= match & blink;
  end

endmodule
