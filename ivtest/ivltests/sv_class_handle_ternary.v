// Verify conditional operator ?: on class handles including 0, 1, X/Z
// conditions, identical handles under X, null branches, and inheritance
// (Upstream #1857).
class Base;
  int id;
  function new(int i);
    id = i;
  endfunction
endclass

class Derived extends Base;
  function new(int i);
    super.new(i);
  endfunction
endclass

module m;
  Base a, b, q;
  Derived d1, d2;
  logic s;

  initial begin
    a = new(10);
    b = new(20);
    d1 = new(30);
    d2 = new(40);

    s = 1'b1;
    q = s ? a : b;
    if (q != a || q.id !== 10) begin $display("FAILED 1"); $finish; end

    s = 1'b0;
    q = s ? a : b;
    if (q != b || q.id !== 20) begin $display("FAILED 2"); $finish; end

    // Unknown condition with distinct handles yields null.
    s = 1'bx;
    q = s ? a : b;
    if (q != null) begin $display("FAILED 3"); $finish; end

    // Unknown condition with identical handles preserves the handle.
    q = s ? a : a;
    if (q != a || q.id !== 10) begin $display("FAILED 4"); $finish; end

    // Null on one branch.
    s = 1'b1;
    q = s ? null : b;
    if (q != null) begin $display("FAILED 5"); $finish; end
    s = 1'b0;
    q = s ? null : b;
    if (q != b) begin $display("FAILED 6"); $finish; end

    // Derived handles assigned to base handle via nested ternary.
    s = 1'b0;
    q = s ? a : (1'b1 ? d1 : d2);
    if (q != d1 || q.id !== 30) begin $display("FAILED 7"); $finish; end

    $display("PASSED");
  end
endmodule
