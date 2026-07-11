module display_format_overflow;
  string result;

  initial begin
    result = $sformatf("%2147483648d", 1);
    if (result != "1") begin
      $display("FAILED: unexpected width fallback '%s'", result);
      $finish;
    end

    result = $sformatf("%.2147483648f", 1.5);
    $display("PASSED");
  end
endmodule
