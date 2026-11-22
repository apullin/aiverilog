// Verify calling outer/package functions and tasks as statements (and void'
// casts) from static class methods and tasks (Upstream #1870).
int log_sum = 0;

function void pf(int v);
  log_sum += v;
endfunction

function int pg(int v);
  log_sum += v * 10;
  return v + 1;
endfunction

task automatic pt(int v);
  log_sum += v * 100;
endtask

package p;
  int p_hits = 0;
  function void bump();
    p_hits += 1;
  endfunction
endpackage

class Q;
  static function void sf();
    pf(3);
    pg(4);
    void'(pg(2));
    p::bump();
  endfunction
  static task st();
    pt(5);
    pf(1);
  endtask
endclass

module m;
  initial begin
    Q::sf();
    Q::st();
    if (log_sum !== (3 + 40 + 20 + 500 + 1) || p::p_hits !== 1) begin
      $display("FAILED log_sum=%0d p_hits=%0d", log_sum, p::p_hits);
      $finish;
    end
    $display("PASSED");
  end
endmodule
