// Verify that parameterized class specializations distinguish value
// parameters with different signedness, bit widths, or string vs integer
// types (IEEE 1800-2017 8.25.1).

class C #(parameter P = 0);
  function int get_int(); return P; endfunction
  function int get_bits(); return $bits(P); endfunction
  function bit is_neg(); return P < 0; endfunction
endclass

class R #(parameter real V = 0.0);
  static int tag = 0;
endclass

module test;
  C #(1'sb1) s1;
  C #(1'b1)  u1;
  C #(8'd1)  w8;
  C #("A")   cs;
  C #(8'd65) ci;
  R #(0.0 / 0.0) rnan1;
  R #(0.0 / 0.0) rnan2;

  initial begin
    s1 = new();
    u1 = new();
    w8 = new();
    cs = new();
    ci = new();
    rnan1 = new();
    rnan2 = rnan1;
    rnan1.tag = 77;

    if (s1.get_int() !== -1 || s1.get_bits() !== 1 || !s1.is_neg()) begin
      $display("FAILED: s1 got %0d (%0d, neg=%0b)", s1.get_int(), s1.get_bits(), s1.is_neg());
      $finish;
    end
    if (u1.get_int() !== 1 || u1.get_bits() !== 1 || u1.is_neg()) begin
      $display("FAILED: u1 got %0d (%0d, neg=%0b)", u1.get_int(), u1.get_bits(), u1.is_neg());
      $finish;
    end
    if (w8.get_int() !== 1 || w8.get_bits() !== 8 || w8.is_neg()) begin
      $display("FAILED: w8 got %0d (%0d, neg=%0b)", w8.get_int(), w8.get_bits(), w8.is_neg());
      $finish;
    end
    if (cs.get_int() !== 65 || ci.get_int() !== 65) begin
      $display("FAILED: cs/ci");
      $finish;
    end
    if (rnan2.tag !== 77) begin
      $display("FAILED: rnan static tag %0d", rnan2.tag);
      $finish;
    end
    $display("PASSED");
  end
endmodule
