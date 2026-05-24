// Test for GitHub issue #1291
// A pathological input where two instances of a module with an
// `always @*` block sharing aliased ports used to abort iverilog
// with `assert(net)' in ivl_nexus_ptrs (t-dll-api.cc:1791). The vvp
// code generator must now report a "sorry" diagnostic instead. The
// design is intentionally meaningless (one instance has aliased
// inputs); the test only verifies we no longer crash.

module pass(output reg out, input wire in, input wire ctrl);
  always @* begin
    if (ctrl === 1) begin
      out <= in;
    end
  end
endmodule

module ROM();
 wire a, b, c, d;
 pass p1361 (b, a, c);
 pass p1814 (d, a, a);
endmodule
