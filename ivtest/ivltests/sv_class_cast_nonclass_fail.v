// Check that $cast() to a non-class, non-enumeration target is
// reported as not supported.

module test;

  int c;
  int rc;

  initial begin
    rc = $cast(c, 1);
    $display("FAILED");
  end

endmodule
