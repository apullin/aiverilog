// Regression test for upstream #1552:
// Out-of-bounds or undefined-index read of a 2-state fixed-size unpacked
// array must return '0 (IEEE 1800-2023 7.4.5 Table 7-1), whereas a 4-state
// unpacked array returns 'x.
module top;
  int         ai[2];
  bit  [11:0] ab[1:2];
  logic [7:0] al[2];
  string      as[2];

  int         idx_oob = 5;
  logic [3:0] idx_x   = 4'bx;

  wire [31:0] w_oob = ai[idx_oob];
  wire [31:0] w_x   = ai[idx_x];

  logic [31:0] got_i;
  logic [11:0] got_b;
  logic [7:0]  got_l;
  string       got_s;

  initial begin
    ai[0] = 32'hdead_beef;
    ai[1] = 32'hcafe_babe;
    ab[1] = 12'hfff;
    ab[2] = 12'haaa;
    al[0] = 8'h55;
    al[1] = 8'haa;
    as[0] = "hello";
    as[1] = "world";
    #1;

    // Constant OOB and undefined index on 2-state arrays -> '0 (=== check!)
    got_i = ai[5];
    if (got_i !== 32'd0) begin
      $display("FAILED const ai[5]: %b", got_i);
      $finish;
    end
    got_i = ai[4'bx];
    if (got_i !== 32'd0) begin
      $display("FAILED const ai['x]: %b", got_i);
      $finish;
    end
    got_b = ab[0];
    if (got_b !== 12'd0) begin
      $display("FAILED const ab[0]: %b", got_b);
      $finish;
    end

    // Dynamic OOB and undefined index on 2-state arrays -> '0
    got_i = ai[idx_oob];
    if (got_i !== 32'd0) begin
      $display("FAILED dyn ai[idx_oob]: %b", got_i);
      $finish;
    end
    got_i = ai[idx_x];
    if (got_i !== 32'd0) begin
      $display("FAILED dyn ai[idx_x]: %b", got_i);
      $finish;
    end
    got_b = ab[idx_oob];
    if (got_b !== 12'd0) begin
      $display("FAILED dyn ab[idx_oob]: %b", got_b);
      $finish;
    end

    // Continuous assignment port read (.array/port)
    if (w_oob !== 32'd0 || w_x !== 32'd0) begin
      $display("FAILED net port w_oob=%b w_x=%b", w_oob, w_x);
      $finish;
    end

    // 4-state unpacked array still returns 'x
    got_l = al[5];
    if (got_l !== 8'hxx) begin
      $display("FAILED const al[5]: %b", got_l);
      $finish;
    end
    got_l = al[idx_oob];
    if (got_l !== 8'hxx) begin
      $display("FAILED dyn al[idx_oob]: %b", got_l);
      $finish;
    end

    // Constant OOB on string unpacked array (previously hit ivl_assert!)
    got_s = as[5];
    if (got_s != "") begin
      $display("FAILED const as[5]: '%s'", got_s);
      $finish;
    end

    $display("PASSED");
  end
endmodule
