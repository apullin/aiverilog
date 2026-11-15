// Verify -tblif handles feedthrough aliased ports, >=32-bit XOR/XNOR
// reductions, and >=32-bit shift widths without assertions or shift UB.
module top(
  input wire [63:0] a,
  input wire [32:0] b,
  output wire [63:0] y_pass,
  output wire y_xor,
  output wire y_xnor,
  output wire [32:0] y_shl
);
  assign y_pass = a;
  assign y_xor  = ^a;
  assign y_xnor = ~^a;
  assign y_shl  = b << (a[32:0] & 33'd7);
endmodule
