// Regression test for GitHub #1551: writing a property through a null
// class handle must emit a source-located runtime error instead of asserting.
class C;
  int x;
endclass

module top;
  C c;
  initial begin
    c.x = 1;
    $display("FAILED: continued past null write");
  end
endmodule
