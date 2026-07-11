module scanf_trailing_percent_fail;
  integer value;
  integer rc;

  initial begin
    rc = $sscanf("x", "%", value);
  end
endmodule
