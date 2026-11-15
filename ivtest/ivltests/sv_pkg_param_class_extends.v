// Verify that $unit classes and typedefs can extend and specialize
// parameterized classes declared in packages, and that $unit:: qualified
// type references preserve lexical position.

package u_pkg;
  class PBox #(parameter int W = 4, type T = int);
    T val;
    logic [W-1:0] mask;
    extern function new(T init_v);
    extern virtual function int score(const ref int bias);
  endclass
  function PBox::new(T init_v);
    val = init_v;
    mask = W'(init_v) ^ {W{1'b1}};
  endfunction
  function int PBox::score(const ref int bias);
    return int'(val) + int'(mask) + bias;
  endfunction
endpackage

class SubBox #(parameter int SW = 8, type ST = byte) extends u_pkg::PBox #(SW, ST);
  int extra;
  function new(ST v, int e);
    super.new(v);
    extra = e;
  endfunction
  virtual function int score(const ref int bias);
    return super.score(bias) + extra;
  endfunction
endclass

typedef $unit::SubBox #(8, byte) unit_sub_t;

module test;
  import u_pkg::*;
  PBox #(8, byte) base_h;
  unit_sub_t sub_h;
  int bias = 10;

  initial begin
    sub_h = new(8'd5, 7);
    base_h = sub_h;
    // val=5, mask=8'hfa=250, bias=10, extra=7 -> 272
    if (base_h.score(bias) !== 272) begin
      $display("FAILED: got %0d, expected 272", base_h.score(bias));
      $finish;
    end
    $display("PASSED");
  end
endmodule
