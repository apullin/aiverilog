// Regression test for audit issue #161:
// Out-of-bounds read on an allocated-but-empty queue variable or class
// property must return default ('x for 4-state, '0 for 2-state) without
// dereferencing queue[0] or aborting vvp.
module top;
  class box_t;
    logic [7:0] ql[$];
    int         qi[$];
  endclass

  logic [7:0] ql[$];
  int         qi[$];
  logic [7:0] xl;
  int         xi;
  box_t       b;

  initial begin
    // Allocate and drain module-scope queues
    ql.push_back(8'h42);
    void'(ql.pop_front());
    xl = ql[0];
    if (xl !== 8'hxx) begin
      $display("FAILED empty logic queue[0]: %b", xl);
      $finish;
    end

    qi.push_back(123);
    qi.delete();
    xi = qi[0];
    if (xi !== 0) begin
      $display("FAILED empty int queue[0]: %0d", xi);
      $finish;
    end

    // Allocate and drain class-property queues
    b = new();
    b.ql.push_back(8'haa);
    void'(b.ql.pop_back());
    xl = b.ql[0];
    if (xl !== 8'hxx) begin
      $display("FAILED empty class logic queue[0]: %b", xl);
      $finish;
    end

    b.qi.push_back(77);
    void'(b.qi.pop_front());
    xi = b.qi[0];
    if (xi !== 0) begin
      $display("FAILED empty class int queue[0]: %0d", xi);
      $finish;
    end

    $display("PASSED");
  end
endmodule
