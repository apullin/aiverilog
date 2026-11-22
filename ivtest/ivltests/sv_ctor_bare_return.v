// Verify bare 'return;' inside in-body, out-of-body extern, and super-chained
// class constructors (Upstream #1872).
class Base;
  int b;
  function new(int x);
    if (x < 0) begin
      b = -1;
      return;
    end
    b = x;
  endfunction
endclass

class Derived extends Base;
  int d;
  extern function new(int x, int y);
endclass

function Derived::new(int x, int y);
  super.new(x);
  if (y == 0) begin
    d = 99;
    return;
  end
  d = y;
endfunction

module m;
  Derived o1, o2, o3;
  initial begin
    o1 = new(-5, 7);
    if (o1 == null || o1.b !== -1 || o1.d !== 7) begin
      $display("FAILED o1 b=%0d d=%0d", o1.b, o1.d);
      $finish;
    end
    o2 = new(4, 0);
    if (o2 == null || o2.b !== 4 || o2.d !== 99) begin
      $display("FAILED o2 b=%0d d=%0d", o2.b, o2.d);
      $finish;
    end
    o3 = new(8, 12);
    if (o3 == null || o3.b !== 8 || o3.d !== 12) begin
      $display("FAILED o3 b=%0d d=%0d", o3.b, o3.d);
      $finish;
    end
    $display("PASSED");
  end
endmodule
