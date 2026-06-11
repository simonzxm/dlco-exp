module tm (
    input clk,
    input [7:0] datain,
    input reset,
    output reg [7:0] dataout,
    output reg move,
    output reg halt
);

  // add your code here
  reg [2:0] state;

  always @(posedge clk) begin
    if (reset) begin
      state   <= 3'd0;
      dataout <= 8'h00;
      move    <= 1'b0;
      halt    <= 1'b0;
    end else begin
      case (state)
        3'd0: begin
          if (datain == 8'h00) begin
            state   <= 3'd7;
            dataout <= 8'h54;
            move    <= 1'b0;
            halt    <= 1'b1;
          end else if (datain == 8'h28) begin
            state   <= 3'd1;
            dataout <= 8'h00;
            move    <= 1'b0;
            halt    <= 1'b0;
          end else if (datain == 8'h29) begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end else begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end
        end
        3'd1: begin
          if (datain == 8'h00) begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end else if (datain == 8'h28) begin
            state   <= 3'd1;
            dataout <= 8'h28;
            move    <= 1'b0;
            halt    <= 1'b0;
          end else if (datain == 8'h29) begin
            state   <= 3'd2;
            dataout <= 8'h29;
            move    <= 1'b0;
            halt    <= 1'b0;
          end else begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end
        end
        3'd2: begin
          if (datain == 8'h00) begin
            state   <= 3'd3;
            dataout <= 8'h00;
            move    <= 1'b1;
            halt    <= 1'b0;
          end else if (datain == 8'h28) begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end else if (datain == 8'h29) begin
            state   <= 3'd2;
            dataout <= 8'h29;
            move    <= 1'b0;
            halt    <= 1'b0;
          end else begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end
        end
        3'd3: begin
          if (datain == 8'h29) begin
            state   <= 3'd4;
            dataout <= 8'h00;
            move    <= 1'b1;
            halt    <= 1'b0;
          end else begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end
        end
        3'd4: begin
          if (datain == 8'h00) begin
            state   <= 3'd0;
            dataout <= 8'h00;
            move    <= 1'b0;
            halt    <= 1'b0;
          end else if (datain == 8'h28) begin
            state   <= 3'd4;
            dataout <= 8'h28;
            move    <= 1'b1;
            halt    <= 1'b0;
          end else if (datain == 8'h29) begin
            state   <= 3'd4;
            dataout <= 8'h29;
            move    <= 1'b1;
            halt    <= 1'b0;
          end else begin
            state   <= 3'd7;
            dataout <= 8'h46;
            move    <= 1'b0;
            halt    <= 1'b1;
          end
        end
        3'd7: begin
          halt <= 1'b1;
        end
        default: begin
          state <= 3'd7;
          halt  <= 1'b1;
        end
      endcase
    end
  end

endmodule
