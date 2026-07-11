module timeformat_invalid_range;
  string result;

  initial begin
    $timeformat(-2147483648, 0, "", 0);
    result = $sformatf("%t", 1);

    $timeformat(0, -1, "", 0);
    result = $sformatf("%t", 1);
    $timeformat(0, 2147483647, "", 0);
    result = $sformatf("%t", 1);

    $timeformat(0, 0, "", -1);
    result = $sformatf("%t", 1);
    $timeformat(0, 0, "", 2147483647);
    result = $sformatf("%t", 1);

    $display("PASSED");
  end
endmodule
