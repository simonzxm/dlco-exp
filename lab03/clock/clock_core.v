module clock_core (
    input wire clk,
    input wire tick_1s,
    input wire setting,
    input wire [1:0] adj_field,  // 0=hour, 1=min, 2=sec
    input wire adj_up,
    input wire adj_down,
    output reg [3:0] hour_tens,
    output reg [3:0] hour_ones,
    output reg [3:0] min_tens,
    output reg [3:0] min_ones,
    output reg [3:0] sec_tens,
    output reg [3:0] sec_ones
);

  // Normal tick: seconds increment with carry
  // Setting mode: clock keeps running, adj_up/adj_down adjust selected field

  // --- Second counting ---
  wire sec_carry = (sec_tens == 5) && (sec_ones == 9);
  wire min_carry = (min_tens == 5) && (min_ones == 9);
  wire hour_carry = (hour_tens == 2) && (hour_ones == 3);

  always @(posedge clk) begin
    // Second: normal tick
    if (tick_1s) begin
      if (sec_ones == 9) begin
        sec_ones <= 0;
        if (sec_tens == 5) sec_tens <= 0;
        else sec_tens <= sec_tens + 1;
      end else begin
        sec_ones <= sec_ones + 1;
      end
    end

    // Second: adjustment
    if (setting && adj_field == 2'd2) begin
      if (adj_up) begin
        if (sec_carry) begin
          sec_tens <= 0;
          sec_ones <= 0;
        end else if (sec_ones == 9) begin
          sec_ones <= 0;
          sec_tens <= sec_tens + 1;
        end else begin
          sec_ones <= sec_ones + 1;
        end
      end
      if (adj_down) begin
        if (sec_tens == 0 && sec_ones == 0) begin
          sec_tens <= 5;
          sec_ones <= 9;
        end else if (sec_ones == 0) begin
          sec_ones <= 9;
          sec_tens <= sec_tens - 1;
        end else begin
          sec_ones <= sec_ones - 1;
        end
      end
    end
  end

  // --- Minute counting ---
  always @(posedge clk) begin
    // Minute: normal carry from second
    if (tick_1s && sec_carry) begin
      if (min_ones == 9) begin
        min_ones <= 0;
        if (min_tens == 5) min_tens <= 0;
        else min_tens <= min_tens + 1;
      end else begin
        min_ones <= min_ones + 1;
      end
    end

    // Minute: adjustment
    if (setting && adj_field == 2'd1) begin
      if (adj_up) begin
        if (min_carry) begin
          min_tens <= 0;
          min_ones <= 0;
        end else if (min_ones == 9) begin
          min_ones <= 0;
          min_tens <= min_tens + 1;
        end else begin
          min_ones <= min_ones + 1;
        end
      end
      if (adj_down) begin
        if (min_tens == 0 && min_ones == 0) begin
          min_tens <= 5;
          min_ones <= 9;
        end else if (min_ones == 0) begin
          min_ones <= 9;
          min_tens <= min_tens - 1;
        end else begin
          min_ones <= min_ones - 1;
        end
      end
    end
  end

  // --- Hour counting ---
  always @(posedge clk) begin
    // Hour: normal carry from minute
    if (tick_1s && sec_carry && min_carry) begin
      if (hour_carry) begin
        hour_tens <= 0;
        hour_ones <= 0;
      end else if (hour_ones == 9) begin
        hour_ones <= 0;
        hour_tens <= hour_tens + 1;
      end else begin
        hour_ones <= hour_ones + 1;
      end
    end

    // Hour: adjustment
    if (setting && adj_field == 2'd0) begin
      if (adj_up) begin
        if (hour_carry) begin
          hour_tens <= 0;
          hour_ones <= 0;
        end else if (hour_ones == 9) begin
          hour_ones <= 0;
          hour_tens <= hour_tens + 1;
        end else begin
          hour_ones <= hour_ones + 1;
        end
      end
      if (adj_down) begin
        if (hour_tens == 0 && hour_ones == 0) begin
          hour_tens <= 2;
          hour_ones <= 3;
        end else if (hour_ones == 0) begin
          hour_ones <= 9;
          hour_tens <= hour_tens - 1;
        end else begin
          hour_ones <= hour_ones - 1;
        end
      end
    end
  end

endmodule
