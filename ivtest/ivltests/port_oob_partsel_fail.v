// Verify out-of-range explicit port part-selects and undeclared concatenated
// subports report errors cleanly instead of crashing ivl.
module dummy (.B(A[128:0]));
  input [2:1] A;
endmodule

module concat_m (.p({undecl_a, decl_b}));
  output [1:0] decl_b;
endmodule

module top;
  wire [128:0] w1;
  wire [3:0] w2;
  dummy u1(.B(w1));
  concat_m u2(.p(w2));
endmodule
