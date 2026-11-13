// Reading a property through a null class handle must emit a runtime error.
class C;
  int x;
endclass

module top;
  C c;
  int y;
  initial begin
    y = c.x;
    $display("FAILED: continued past null read (%0d)", y);
  end
endmodule
