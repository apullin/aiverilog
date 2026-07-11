module scanf_string_format;
  string format;
  reg [7:0] value;
  integer rc;

  initial begin
    format = "%c";
    rc = $sscanf("A", format, value);
    if (rc != 1 || value != "A") begin
      $display("FAILED: string format rc=%0d value=%02h", rc, value);
      $finish;
    end
    $display("PASSED");
  end
endmodule
