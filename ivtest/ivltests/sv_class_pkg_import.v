// Test package import declarations inside a class body (Upstream #1828).
package p_types;
  typedef logic [15:0] halfword_t;
  typedef enum int { MODE_IDLE = 3, MODE_RUN = 9 } mode_e;
endpackage

package p_funcs;
  int hits = 10;
  localparam int SCALE = 4;
  function automatic int one();
    return 1;
  endfunction
  task automatic bump(input int d);
    hits = hits + d;
  endtask
endpackage

class C;
  import p_types::*;
  import p_funcs::one;
  import p_funcs::bump;
  import p_funcs::SCALE;
  import p_funcs::hits;

  halfword_t hw;
  mode_e m;

  function new();
    hw = 16'h1234;
    m = MODE_RUN;
  endfunction

  task do_bump();
    bump(5);
  endtask

  function int compute();
    return one() + SCALE + int'(m) + hits;
  endfunction
endclass

module top;
  initial begin
    C c;
    c = new;
    c.do_bump();
    if (c.hw !== 16'h1234) begin
      $display("FAILED: hw=%h", c.hw);
      $finish;
    end
    if (c.compute() !== (1 + 4 + 9 + 15)) begin
      $display("FAILED: compute=%0d", c.compute());
      $finish;
    end
    $display("PASSED");
  end
endmodule
