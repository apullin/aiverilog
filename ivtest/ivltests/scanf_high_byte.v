module scanf_high_byte;
  reg [7:0] source;
  reg [7:0] value;
  integer rc;

  initial begin
    source = 8'h80;
    rc = $sscanf(source, "%c", value);
    if (rc != 1 || value != 8'h80) begin
      $display("FAILED: 80 scan rc=%0d value=%02h", rc, value);
      $finish;
    end

    source = 8'hff;
    rc = $sscanf(source, "%c", value);
    if (rc != 1 || value != 8'hff) begin
      $display("FAILED: ff scan rc=%0d value=%02h", rc, value);
      $finish;
    end

    $display("PASSED");
  end
endmodule
