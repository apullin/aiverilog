// Verify static method/property/parameter access through a class type
// parameter T::f() inside a parameterized class whose default T is non-class
// (Upstream #1868).
class R #(type T = int);
  function string tag_of_t();
    return T::tag();
  endfunction
  static function int code_of_t();
    return T::CODE + T::s_bias;
  endfunction
endclass

class A;
  localparam int CODE = 10;
  static int s_bias = 1;
  static function string tag();
    return "A";
  endfunction
endclass

class B;
  localparam int CODE = 20;
  static int s_bias = 2;
  static function string tag();
    return "B";
  endfunction
endclass

module m;
  R #(A) xa;
  R #(B) xb;
  initial begin
    xa = new;
    xb = new;
    if (xa.tag_of_t() != "A" || xb.tag_of_t() != "B") begin
      $display("FAILED tags %s %s", xa.tag_of_t(), xb.tag_of_t());
      $finish;
    end
    if (R#(A)::code_of_t() !== 11 || R#(B)::code_of_t() !== 22) begin
      $display("FAILED codes %0d %0d", R#(A)::code_of_t(), R#(B)::code_of_t());
      $finish;
    end
    $display("PASSED");
  end
endmodule
