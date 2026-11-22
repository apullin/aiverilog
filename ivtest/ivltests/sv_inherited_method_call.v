// Test unqualified calls to inherited base-class methods in both in-body and
// out-of-body (extern) derived-class methods (Upstream #1864).
class GrandBase;
  int log_sum = 0;

  function string hdr();
    return "x";
  endfunction

  virtual function int vtag();
    return 10;
  endfunction

  static function int sbase();
    return 42;
  endfunction

  task add_log(input int delta);
    log_sum = log_sum + delta;
  endtask
endclass

class Base #(int K = 5) extends GrandBase;
  function int mid();
    return vtag() + K;
  endfunction
endclass

class Derived extends Base #(7);
  virtual function int vtag();
    return 20;
  endfunction

  function string in_body();
    return {hdr(), $sformatf(":%0d", mid())};
  endfunction

  extern function string emit();
  extern task run_work();
  extern static function int check_static();
endclass

function string Derived::emit();
  return {hdr(), $sformatf(":%0d", mid())};
endfunction

task Derived::run_work();
  add_log(11);
  add_log(mid());
endtask

function int Derived::check_static();
  return sbase() + 8;
endfunction

module top;
  Derived d = new;
  initial begin
    if (d.emit() != "x:27") begin
      $display("FAILED: emit=%s", d.emit());
      $finish;
    end
    if (d.in_body() != "x:27") begin
      $display("FAILED: in_body=%s", d.in_body());
      $finish;
    end
    d.run_work();
    if (d.log_sum !== 38) begin
      $display("FAILED: log_sum=%0d", d.log_sum);
      $finish;
    end
    if (Derived::check_static() !== 50) begin
      $display("FAILED: check_static=%0d", Derived::check_static());
      $finish;
    end
    $display("PASSED");
  end
endmodule
