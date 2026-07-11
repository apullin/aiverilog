module scanf_raw_wide_dest;
  reg [31:0] two_state;
  reg [31:0] four_state;
  integer rc;

  initial begin
    rc = $sscanf("ABCDEFGH", "%33u", two_state);
    if (rc != 1 || two_state != 32'h44434241) begin
      $display("FAILED: two-state rc=%0d value=%08h", rc, two_state);
      $finish;
    end

    rc = $sscanf("ABCDEFGHIJKLMNOP", "%33z", four_state);
    if (rc != 1) begin
      $display("FAILED: four-state rc=%0d", rc);
      $finish;
    end

    $display("PASSED");
  end
endmodule
