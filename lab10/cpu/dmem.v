module dmem (
    input [16:0] addr,
    output reg [31:0] dataout,
    input [31:0] datain,
    input wrclk,
    input rdclk,
    input [2:0] memop,
    input we
);

  wire [14:0] word_addr = addr[16:2];
  wire [ 1:0] byte_offset = addr[1:0];

  reg  [ 3:0] wea;
  reg  [31:0] dina;
  wire [31:0] doutb;

  always @(*) begin
    wea  = 4'b0000;
    dina = 32'b0;
    if (we) begin
      case (memop)
        3'b000: begin
          case (byte_offset)
            2'b00: begin
              wea  = 4'b0001;
              dina = {24'b0, datain[7:0]};
            end
            2'b01: begin
              wea  = 4'b0010;
              dina = {16'b0, datain[7:0], 8'b0};
            end
            2'b10: begin
              wea  = 4'b0100;
              dina = {8'b0, datain[7:0], 16'b0};
            end
            2'b11: begin
              wea  = 4'b1000;
              dina = {datain[7:0], 24'b0};
            end
            default: begin
              wea  = 4'b0000;
              dina = 32'b0;
            end
          endcase
        end
        3'b001: begin
          case (byte_offset)
            2'b00: begin
              wea  = 4'b0011;
              dina = {16'b0, datain[15:0]};
            end
            2'b10: begin
              wea  = 4'b1100;
              dina = {datain[15:0], 16'b0};
            end
            default: begin
              wea  = 4'b0000;
              dina = 32'b0;
            end
          endcase
        end
        3'b010: begin
          wea  = 4'b1111;
          dina = datain;
        end
        default: begin
          wea  = 4'b0000;
          dina = 32'b0;
        end
      endcase
    end
  end

  blk_mem_gen_0 mem_inst (
      .clka (wrclk),
      .wea  (wea),
      .addra(word_addr),
      .dina (dina),
      .clkb (rdclk),
      .addrb(word_addr),
      .doutb(doutb)
  );

  always @(*) begin
    case (memop)
      3'b000: begin
        case (byte_offset)
          2'b00:   dataout = {{24{doutb[7]}}, doutb[7:0]};
          2'b01:   dataout = {{24{doutb[15]}}, doutb[15:8]};
          2'b10:   dataout = {{24{doutb[23]}}, doutb[23:16]};
          2'b11:   dataout = {{24{doutb[31]}}, doutb[31:24]};
          default: dataout = 32'b0;
        endcase
      end
      3'b001: begin
        case (byte_offset)
          2'b00:   dataout = {{16{doutb[15]}}, doutb[15:0]};
          2'b10:   dataout = {{16{doutb[31]}}, doutb[31:16]};
          default: dataout = 32'b0;
        endcase
      end
      3'b010:  dataout = doutb;
      3'b100: begin
        case (byte_offset)
          2'b00:   dataout = {24'b0, doutb[7:0]};
          2'b01:   dataout = {24'b0, doutb[15:8]};
          2'b10:   dataout = {24'b0, doutb[23:16]};
          2'b11:   dataout = {24'b0, doutb[31:24]};
          default: dataout = 32'b0;
        endcase
      end
      3'b101: begin
        case (byte_offset)
          2'b00:   dataout = {16'b0, doutb[15:0]};
          2'b10:   dataout = {16'b0, doutb[31:16]};
          default: dataout = 32'b0;
        endcase
      end
      default: dataout = 32'b0;
    endcase
  end

endmodule
