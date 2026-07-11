module display_time_wide;
  reg [4095:0] value;
  string result;

  initial begin
    value = {4096{1'b1}};
    result = $sformatf("%t", value);
    if (result.len() != 1234) begin
      $display("FAILED: expected 1234 digits, got %0d", result.len());
      $finish;
    end
    $display("PASSED");
  end
endmodule
