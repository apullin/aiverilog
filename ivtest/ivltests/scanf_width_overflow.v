module scanf_width_overflow;
  reg [31:0] value;
  integer rc;

  initial begin
    rc = $sscanf("abcd", "%4294967294u", value);
    if (rc > 0) begin
      $display("FAILED: oversized raw width unexpectedly matched");
      $finish;
    end

    rc = $sscanf("123", "%4294967296d", value);
    if (rc != 1 || value != 123) begin
      $display("FAILED: unlimited-width fallback did not match");
      $finish;
    end

    $display("PASSED");
  end
endmodule
