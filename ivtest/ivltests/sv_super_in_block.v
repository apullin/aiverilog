// Verify super.method() and super.prop inside named/unnamed begin-end blocks
// and loops that declare local variables (Upstream #1865).
class B;
  int base_v = 10;
  virtual task f(output int out);
    out = base_v + 5;
  endtask
  virtual function int g(int a);
    return base_v + a;
  endfunction
endclass

class D extends B;
  int base_v = 100;
  task f(output int out);
    begin
      int local_tmp = 3;
      super.f(out);
      out = out + local_tmp;
    end
  endtask
  function int g(int a);
    int sum = 0;
    for (int i = 0; i < 2; i++) begin : blk
      int step;
      step = super.g(a + i) + super.base_v;
      sum += step;
    end
    return sum;
  endfunction
endclass

module m;
  D d = new;
  int r;
  initial begin
    d.f(r);
    if (r !== 18) begin $display("FAILED f r=%0d", r); $finish; end
    if (d.g(2) !== (12 + 10 + 13 + 10)) begin
      $display("FAILED g=%0d", d.g(2));
      $finish;
    end
    $display("PASSED");
  end
endmodule
