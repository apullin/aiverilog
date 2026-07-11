module scanf_high_format_byte;
  string source;
  string format;
  reg [7:0] value;
  integer rc;

  initial begin
    source = {8'hff, "A"};
    format = {8'hff, "%c"};
    rc = $sscanf(source, format, value);
    if (rc != 1 || value != "A") begin
      $display("FAILED: high format byte rc=%0d value=%02h", rc, value);
      $finish;
    end
    $display("PASSED");
  end
endmodule
