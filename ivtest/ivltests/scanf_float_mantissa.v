module scanf_float_mantissa;
  real value;
  integer rc;
  integer pass = 1;

  initial begin
    value = 7.0;
    rc = $sscanf(".", "%f", value);
    if (rc != 0 || value != 7.0) begin
      $display("FAILED: bare decimal rc=%0d value=%f", rc, value);
      pass = 0;
    end

    rc = $sscanf("+.", "%e", value);
    if (rc != 0 || value != 7.0) begin
      $display("FAILED: signed decimal rc=%0d value=%f", rc, value);
      pass = 0;
    end

    rc = $sscanf("-.5", "%g", value);
    if (rc != 1 || value != -0.5) begin
      $display("FAILED: fractional value rc=%0d value=%f", rc, value);
      pass = 0;
    end

    if (pass) $display("PASSED");
  end
endmodule
