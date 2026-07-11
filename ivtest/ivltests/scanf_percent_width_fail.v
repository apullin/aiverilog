module scanf_percent_width_fail;
  integer value;
  integer rc;

  initial begin
    rc = $sscanf("%", "%1%", value);
  end
endmodule
