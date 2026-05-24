// Test for GitHub issue #1276
// A procedural continuous assignment ('assign' inside an always or
// initial block) does not support a concatenation as its L-value.
// iverilog used to assert at code-gen time; it must now report a
// proper error during elaboration.

module foo(output out, input a, input b);
  and(out, a, b);
endmodule

module foo_tb;
  reg a, b;
  wire out;
  foo DUT(out, a, b);
  initial begin
    for (integer i = 0; i < 4; i++) begin
        assign {a, b} = i;       // illegal: concat as LHS of procedural assign
        $display(a, b, out);
    end
  end
endmodule
