// Regression test for upstream #1061:
// Simultaneous local/protected and virtual class method qualifiers in any
// legal order, including polymorphic dispatch across inheritance.
class base_c;
  local virtual function int lv_fn();
    return 10;
  endfunction

  virtual local function int vl_fn();
    return 20;
  endfunction

  protected virtual function int pv_fn();
    return 30;
  endfunction

  virtual protected function int vp_fn();
    return 40;
  endfunction

  protected virtual task pv_task(output int o);
    o = 50;
  endtask

  task run_all(output int total);
    int t;
    pv_task(t);
    total = lv_fn() + vl_fn() + pv_fn() + vp_fn() + t;
  endtask
endclass

class derived_c extends base_c;
  protected virtual function int pv_fn();
    return 300;
  endfunction

  virtual protected function int vp_fn();
    return 400;
  endfunction

  virtual protected task pv_task(output int o);
    o = 500;
  endtask
endclass

module top;
  initial begin
    base_c b;
    derived_c d;
    int got;
    b = new();
    b.run_all(got);
    if (got !== 150) begin
      $display("FAILED base: got %0d", got);
      $finish;
    end
    d = new();
    b = d;
    b.run_all(got);
    if (got !== 1230) begin
      $display("FAILED derived via base: got %0d", got);
      $finish;
    end
    $display("PASSED");
  end
endmodule
