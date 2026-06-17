module mathcop (
    input         clk,
    input         reset,
    input         we,
    input  [ 4:0] addr,
    input  [31:0] wdata,
    output [31:0] rdata
);

  // op: 0 IMUL 1 UDIV 2 UREM 3 FADD 4 FSUB 5 FMUL 6 FDIV 7 ITOF 8 FTOI
  localparam COMB_WAIT = 3'd4;  // settle cycles for the combinational ops
  reg [31:0] rA, rB, result;
  reg  [ 3:0] op;
  reg         busy;
  reg  [ 2:0] cnt;

  wire        op_we = we && !busy && (addr[4:2] == 3'd2);
  wire [ 3:0] nop = wdata[3:0];

  wire [31:0] imul_y = rA * rB;
  wire [31:0] fadd_y, fsub_y, fmul_y, itof_y, ftoi_y;
  fp_addsub u_add (
      .a(rA),
      .b_in(rB),
      .sub(1'b0),
      .y(fadd_y)
  );
  fp_addsub u_sub (
      .a(rA),
      .b_in(rB),
      .sub(1'b1),
      .y(fsub_y)
  );
  fp_mul u_mul (
      .a(rA),
      .b(rB),
      .y(fmul_y)
  );
  fp_cvt u_itof (
      .a (rA),
      .op(1'b0),
      .y (itof_y)
  );
  fp_cvt u_ftoi (
      .a (rA),
      .op(1'b1),
      .y (ftoi_y)
  );

  wire [31:0] comb_y = (op == 4'd0) ? imul_y :
                       (op == 4'd3) ? fadd_y :
                       (op == 4'd4) ? fsub_y :
                       (op == 4'd5) ? fmul_y :
                       (op == 4'd7) ? itof_y :
                       (op == 4'd8) ? ftoi_y : 32'b0;

  wire idiv_start = op_we && (nop == 4'd1 || nop == 4'd2);
  wire fdiv_start = op_we && (nop == 4'd6);

  wire [31:0] idiv_q, idiv_r;
  wire idiv_done;
  intdiv #(32) u_idiv (
      .clk  (clk),
      .reset(reset),
      .start(idiv_start),
      .a    (rA),
      .b    (rB),
      .q    (idiv_q),
      .r    (idiv_r),
      .done (idiv_done)
  );

  wire [31:0] fdiv_y;
  wire        fdiv_done;
  fp_div u_fdiv (
      .clk  (clk),
      .reset(reset),
      .start(fdiv_start),
      .a    (rA),
      .b    (rB),
      .y    (fdiv_y),
      .done (fdiv_done)
  );

  always @(posedge clk) begin
    if (reset) begin
      busy   <= 1'b0;
      result <= 32'b0;
    end else if (we && !busy && addr[4:2] == 3'd0) begin
      rA <= wdata;
    end else if (we && !busy && addr[4:2] == 3'd1) begin
      rB <= wdata;
    end else if (op_we) begin
      op   <= nop;
      busy <= 1'b1;
      cnt  <= 3'b0;
    end else if (busy) begin
      if (op == 4'd1 || op == 4'd2) begin
        if (idiv_done) begin
          result <= (op == 4'd1) ? idiv_q : idiv_r;
          busy   <= 1'b0;
        end
      end else if (op == 4'd6) begin
        if (fdiv_done) begin
          result <= fdiv_y;
          busy   <= 1'b0;
        end
      end else if (cnt == COMB_WAIT) begin
        result <= comb_y;
        busy   <= 1'b0;
      end else begin
        cnt <= cnt + 3'b1;
      end
    end
  end

  assign rdata = (addr[4:2] == 3'd4) ? {31'b0, busy} : result;

endmodule
