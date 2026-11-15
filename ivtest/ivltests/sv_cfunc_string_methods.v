// Verify that SystemVerilog string variables, ports, return values, and
// string methods (len, substr, getc, toupper, tolower, compare, icompare)
// evaluate properly in constant functions without truncating to 1 bit or
// asserting in NetESFunc::evaluate_function.

module test;
  function automatic string xform(input string a, input int i, input int j);
    string empty_def;
    string sub;
    sub = a.substr(i, j);
    return {empty_def, sub.toupper(), "_", a.tolower()};
  endfunction

  function automatic int metrics(input string s);
    return s.len() * 1000
         + int'(s.getc(1))
         + (s.compare("AbC") == 0 ? 10 : 0)
         + (s.icompare("abc") == 0 ? 1 : 0);
  endfunction

  localparam string S_OUT = xform("Hello", 1, 3);
  localparam int    M_OUT = metrics("AbC");

  initial begin
    if (S_OUT != "ELL_hello") begin
      $display("FAILED S_OUT: got '%s', expected 'ELL_hello'", S_OUT);
      $finish;
    end
    // len=3 -> 3000, getc(1)='b'=98, compare==0 -> 10, icompare==0 -> 1 => 3109
    if (M_OUT !== 3109) begin
      $display("FAILED M_OUT: got %0d, expected 3109", M_OUT);
      $finish;
    end
    $display("PASSED");
  end
endmodule
