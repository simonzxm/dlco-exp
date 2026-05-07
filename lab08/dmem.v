module dmem (
    input [31:0] addr,
    output reg [31:0] dataout,
    input [31:0] datain,
    input rdclk,
    input wrclk,
    input [2:0] memop,
    input we
);

  //add your code here
  reg [31:0] mem[0:1023];
  wire [9:0] word_addr = addr[11:2];
  wire [1:0] byte_offset = addr[1:0];
  wire [31:0] data = mem[word_addr];

  always @(posedge rdclk) begin
    case (memop)
      3'b000: begin
        case (byte_offset)
          2'b00:   dataout <= {{24{data[7]}}, data[7:0]};
          2'b01:   dataout <= {{24{data[15]}}, data[15:8]};
          2'b10:   dataout <= {{24{data[23]}}, data[23:16]};
          2'b11:   dataout <= {{24{data[31]}}, data[31:24]};
          default: dataout <= 32'b0;
        endcase
      end
      3'b001: begin
        case (byte_offset)
          2'b00:   dataout <= {{16{data[15]}}, data[15:0]};
          2'b10:   dataout <= {{16{data[31]}}, data[31:16]};
          default: dataout <= 32'b0;
        endcase
      end
      3'b010:  dataout <= data;
      3'b100: begin
        case (byte_offset)
          2'b00:   dataout <= {24'b0, data[7:0]};
          2'b01:   dataout <= {24'b0, data[15:8]};
          2'b10:   dataout <= {24'b0, data[23:16]};
          2'b11:   dataout <= {24'b0, data[31:24]};
          default: dataout <= 32'b0;
        endcase
      end
      3'b101: begin
        case (byte_offset)
          2'b00:   dataout <= {16'b0, data[15:0]};
          2'b10:   dataout <= {16'b0, data[31:16]};
          default: dataout <= 32'b0;
        endcase
      end
      default: dataout <= 32'b0;
    endcase
  end

  always @(posedge wrclk) begin
    if (we) begin
      case (memop)
        3'b000: begin
          case (byte_offset)
            2'b00:   mem[word_addr] = {data[31:8], datain[7:0]};
            2'b01:   mem[word_addr] = {data[31:16], datain[7:0], data[7:0]};
            2'b10:   mem[word_addr] = {data[31:24], datain[7:0], data[15:0]};
            2'b11:   mem[word_addr] = {datain[7:0], data[23:0]};
            default: mem[word_addr] = 32'b0;
          endcase
        end
        3'b001: begin
          case (byte_offset)
            2'b00:   mem[word_addr] = {data[31:16], datain[15:0]};
            2'b10:   mem[word_addr] = {datain[15:0], data[15:0]};
            default: mem[word_addr] = 32'b0;
          endcase
        end
        3'b010:  mem[word_addr] <= datain;
        default: mem[word_addr] <= 32'b0;
      endcase
    end
  end

endmodule
