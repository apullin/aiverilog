module scanf_empty_format;
  string format;
  integer value;
  integer rc;

  initial begin
    format = "";
    rc = $sscanf("abc", format, value);
    if (rc != 0) begin
      $display("FAILED: empty format returned %0d", rc);
      $finish;
    end
    $display("PASSED");
  end
endmodule
