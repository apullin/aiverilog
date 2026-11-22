// Verify static class property initializers calling static methods of the same
// class, including parameterized classes (Upstream #1784).
class C;
  static function bit f();
    return 1'b1;
  endfunction
  static function int calc(int a, int b);
    return a * 10 + b;
  endfunction
  static bit registered = f();
  static int magic = calc(4, 2);
endclass

class P #(int N = 3);
  static function int scale();
    return N * 7;
  endfunction
  static int val = scale();
endclass

module m;
  initial begin
    #0;
    if (C::registered !== 1'b1 || C::magic !== 42) begin
      $display("FAILED reg=%b magic=%0d", C::registered, C::magic);
      $finish;
    end
    if (P#(5)::val !== 35 || P#()::val !== 21) begin
      $display("FAILED P5=%0d Pdef=%0d", P#(5)::val, P#()::val);
      $finish;
    end
    $display("PASSED");
  end
endmodule
