// Verify $realtime, $time, and $stime inside $unit, package, and module-scoped
// class methods with different timescales (Upstream #1867).
`timescale 1ns/100ps

class UnitTimer;
  function realtime rt();
    return $realtime;
  endfunction
  static function realtime srt();
    return $realtime;
  endfunction
endclass

package timer_pkg;
  timeunit 10ns;
  timeprecision 100ps;
  class PkgTimer;
    function realtime rt();
      return $realtime;
    endfunction
  endclass
endpackage

`timescale 100ps/100ps
module m;
  class ModTimer;
    function realtime rt();
      return $realtime;
    endfunction
  endclass

  UnitTimer u = new;
  timer_pkg::PkgTimer p = new;
  ModTimer md = new;

  initial begin
    #15; // 1.5e-9 s ($unit default 1s) = 0.15 * 10ns = 15 * 100ps
    if (u.rt() != 1.5e-9 || UnitTimer::srt() != 1.5e-9) begin
      $display("FAILED unit rt=%e srt=%e", u.rt(), UnitTimer::srt());
      $finish;
    end
    if (p.rt() != 0.15) begin
      $display("FAILED pkg rt=%f", p.rt());
      $finish;
    end
    if (md.rt() != 15.0) begin
      $display("FAILED mod rt=%f", md.rt());
      $finish;
    end
    $display("PASSED");
  end
endmodule
