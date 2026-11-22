// Test chained method calls as statements (Upstream #1829) and reading/writing
// properties on function/method call results (Upstream #1830).
class Leaf;
  int v;
  logic [7:0] b;
  string s;
  int q[$];
  int calls;

  function int val();
    calls = calls + 1;
    return v;
  endfunction

  function void set_v(int nv);
    v = nv;
  endfunction

  task add_v(input int dv);
    v = v + dv;
  endtask
endclass

class Mid;
  Leaf leaf;
  function new();
    leaf = new;
  endfunction
  function Leaf get_leaf();
    return leaf;
  endfunction
endclass

class Root;
  Leaf h;
  Mid m;
  int get_cnt;

  function new();
    h = new;
    m = new;
    get_cnt = 0;
  endfunction

  function Leaf get();
    get_cnt = get_cnt + 1;
    return h;
  endfunction

  function Mid get_mid();
    return m;
  endfunction

  function void self_check();
    this.get().set_v(33);
    void'(this.get().val());
  endfunction
endclass

module top;
  initial begin
    Root r;
    Leaf c;
    r = new;
    c = r.h;
    c.v = 7;
    c.b = 8'ha5;
    c.s = "init";

    // Statement chained calls: non-void, void'(), void function, task
    r.get().val();
    if (c.calls !== 1 || r.get_cnt !== 1) begin
      $display("FAILED: after r.get().val(): calls=%0d get_cnt=%0d", c.calls, r.get_cnt);
      $finish;
    end

    void'(r.get().val());
    if (c.calls !== 2 || r.get_cnt !== 2) begin
      $display("FAILED: after void'(r.get().val()): calls=%0d get_cnt=%0d", c.calls, r.get_cnt);
      $finish;
    end

    // Property read on call result
    if (r.get().v !== 7 || r.get().b[7:4] !== 4'ha || r.get().b[0] !== 1'b1) begin
      $display("FAILED: prop read v=%0d b=%h", r.get().v, r.get().b);
      $finish;
    end

    // Property writes on call result (=, +=, ++, string, array, part-select)
    r.get().v = 20;
    if (c.v !== 20) begin
      $display("FAILED: prop write v=%0d", c.v);
      $finish;
    end

    begin
      int before_cnt;
      before_cnt = r.get_cnt;
      r.get().v += 5;
      r.get().v++;
      if (c.v !== 26 || (r.get_cnt - before_cnt) !== 2) begin
        $display("FAILED: += / ++: v=%0d delta_cnt=%0d", c.v, r.get_cnt - before_cnt);
        $finish;
      end
    end

    r.get().b[3:0] = 4'hc;
    r.get().s = "updated";
    r.get().q.push_back(91);
    if (r.get().b !== 8'hac || r.get().s != "updated" || r.get().q[0] !== 91) begin
      $display("FAILED: b=%h s=%s q[0]=%0d", r.get().b, r.get().s, r.get().q[0]);
      $finish;
    end

    // Multi-hop chains (call -> prop -> call -> prop, call -> task)
    r.get().add_v(4);
    r.get_mid().leaf.v = 55;
    r.get_mid().leaf.add_v(5);
    r.get_mid().get_leaf().add_v(10);
    if (r.get().v !== 30 || r.get_mid().leaf.v !== 70 || r.get_mid().get_leaf().v !== 70) begin
      $display("FAILED: multi-hop v=%0d mid.v=%0d", r.get().v, r.get_mid().leaf.v);
      $finish;
    end

    r.self_check();
    if (c.v !== 33 || c.calls !== 3) begin
      $display("FAILED: self_check v=%0d calls=%0d", c.v, c.calls);
      $finish;
    end

    $display("PASSED");
  end
endmodule
