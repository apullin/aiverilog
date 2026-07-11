module scanf_raw_high_byte;
  string source;
  reg [31:0] value;
  integer rc;

  initial begin
    source = {"ABC", 8'hff};
    rc = $sscanf(source, "%32u", value);
    if (rc != 1) begin
      $display("FAILED: two-state rc=%0d", rc);
      $finish;
    end

    source = {"ABC", 8'hff, "DEF", 8'hff};
    rc = $sscanf(source, "%32z", value);
    if (rc != 1) begin
      $display("FAILED: four-state rc=%0d", rc);
      $finish;
    end

    $display("PASSED");
  end
endmodule
