// Test for GitHub issue #1298
// Conditional (ternary) operator must accept string operands, including
// a string variable on one side and a string literal on the other.

module ivtest;
  reg failed = 1'b0;

  task check_eq(input string actual, input string expected, input string label);
    if (actual != expected) begin
      $display("FAILED %s: got '%s', expected '%s'", label, actual, expected);
      failed = 1'b1;
    end
  endtask

  initial begin : main
    string svar;
    string s1, s2;
    reg cond;

    svar = "v";

    // Case A: short literal + string variable
    cond = 1; check_eq(cond ? "N" : svar,    "N", "A1");
    cond = 0; check_eq(cond ? "N" : svar,    "v", "A2");

    // Case B: longer literal + string variable
    cond = 1; check_eq(cond ? "None" : svar, "None", "B1");
    cond = 0; check_eq(cond ? "None" : svar, "v",    "B2");

    // Case C: literal on the false side
    cond = 1; check_eq(cond ? svar : "Y",    "v", "C1");
    cond = 0; check_eq(cond ? svar : "Y",    "Y", "C2");

    // Case D: two string variables on both sides
    s1 = "First";
    s2 = "Second";
    cond = 1; check_eq(cond ? s1 : s2, "First",  "D1");
    cond = 0; check_eq(cond ? s1 : s2, "Second", "D2");

    if (!failed) $display("PASSED");
  end
endmodule
