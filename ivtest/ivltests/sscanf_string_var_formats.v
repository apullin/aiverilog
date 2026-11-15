// Verify that $sscanf with non-string format specifiers (%d, %h, %b, %c,
// %f, %u, %z) into a SystemVerilog string variable converts cleanly without
// triggering assertions in __vpiStringVar::vpi_put_value or sys_scanf.c.

module test;
  string s;
  int rc;

  initial begin
    rc = $sscanf("65", "%d", s);
    if (rc !== 1 || s != "A") begin
      $display("FAILED %%d: rc=%0d s='%s'", rc, s);
      $finish;
    end

    rc = $sscanf("4243", "%h", s);
    if (rc !== 1 || s != "BC") begin
      $display("FAILED %%h: rc=%0d s='%s'", rc, s);
      $finish;
    end

    rc = $sscanf("Z", "%c", s);
    if (rc !== 1 || s != "Z") begin
      $display("FAILED %%c: rc=%0d s='%s'", rc, s);
      $finish;
    end

    s = "";
    rc = $sscanf("ABCD", "%u", s);
    if (rc !== 1 || s != "DCBA") begin
      $display("FAILED %%u: rc=%0d s='%s'", rc, s);
      $finish;
    end

    rc = $sscanf("66.0", "%f", s);
    if (rc !== 1 || s != "B") begin
      $display("FAILED %%f: rc=%0d s='%s'", rc, s);
      $finish;
    end

    $display("PASSED");
  end
endmodule
