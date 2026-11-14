// Regression test for upstream #1196:
// Array indices wider than 32 bits (both 33..64-bit and >64-bit, unsigned and
// negative signed) with non-zero upper bits must be treated as out-of-bounds
// in procedural reads/writes, VPI $sformatf/$display (&A<>), and continuous
// assignments, rather than truncating to the low 32 bits.
module top;
  reg [32:0] idx33  = {1'b1, 32'h1};
  reg [64:0] idx65  = {1'b1, 64'h1};
  reg signed [33:0] idx_neg = -34'sd4294967295; // low 32 bits == 1!

  integer a4[2];
  int     a2[2];
  wire [31:0] w4 = a4[idx33];
  wire [31:0] w2 = a2[idx33];

  initial begin
    logic [31:0] got4, got2;
    string s4, s2;

    a4[0] = 7;  a4[1] = 10;
    a2[0] = 11; a2[1] = 22;
    #1;

    // VPI &A<> path ($sformatf / $display)
    s4 = $sformatf("%0d", a4[idx33]);
    s2 = $sformatf("%0d", a2[idx33]);
    if (s4 != "x" || s2 != "0") begin
      $display("FAILED VPI &A<> 33-bit: s4='%s' s2='%s'", s4, s2);
      $finish;
    end

    // Procedural expression reads (%load/vec4a) for 33-bit, 65-bit, and negative 34-bit
    got4 = a4[idx33] + 32'd0;
    got2 = a2[idx33];
    if (got4 !== 32'bx || got2 !== 32'd0) begin
      $display("FAILED load 33-bit: got4=%h got2=%h", got4, got2);
      $finish;
    end
    got4 = a4[idx65] + 32'd0;
    got2 = a2[idx65];
    if (got4 !== 32'bx || got2 !== 32'd0) begin
      $display("FAILED load 65-bit: got4=%h got2=%h", got4, got2);
      $finish;
    end
    got4 = a4[idx_neg] + 32'd0;
    if (got4 !== 32'bx) begin
      $display("FAILED load negative 34-bit: got4=%h", got4);
      $finish;
    end

    // Procedural writes (%store/vec4a & NBA %assign/av) must NOT clobber a[1]!
    a4[idx33] = 999;
    a4[idx65] = 888;
    a4[idx_neg] <= 777;
    #1;
    if (a4[1] !== 10 || a4[0] !== 7) begin
      $display("FAILED OOB wide write clobbered array: a4[0]=%0d a4[1]=%0d",
               a4[0], a4[1]);
      $finish;
    end

    // Continuous assignment (.array/port)
    if (w4 !== 32'bx || w2 !== 32'd0) begin
      $display("FAILED continuous array port: w4=%h w2=%h", w4, w2);
      $finish;
    end

    $display("PASSED");
  end
endmodule
