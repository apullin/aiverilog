// Verify $swrite, $swriteh, $sformat, and $sscanf writing to and reading from
// a string class property (Upstream #1859).
class C;
  string s;
  function void run(int n);
    int parsed;
    $swrite(s, "a%0d", n);
    if (s != "a42") begin $display("FAILED swrite=%s", s); $finish; end
    $swriteh(s, 16'hbeef);
    if (s != "beef") begin $display("FAILED swriteh=%s", s); $finish; end
    $sformat(s, "val=%0d", n + 8);
    if (s != "val=50") begin $display("FAILED sformat=%s", s); $finish; end
    if ($sscanf("item_77", "%s", s) != 1 || s != "item_77") begin
      $display("FAILED sscanf=%s", s);
      $finish;
    end
  endfunction
endclass

module m;
  C c = new;
  initial begin
    c.run(42);
    $swrite(c.s, "ext_%s", "ok");
    if (c.s != "ext_ok") begin $display("FAILED ext=%s", c.s); $finish; end
    $display("PASSED");
  end
endmodule
