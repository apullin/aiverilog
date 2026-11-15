// Verify that -tstub handles type parameters in parameterized classes and
// modules without asserting on a null parameter expression.

class Box #(type T = logic [3:0]);
  T item;
endclass

module top #(parameter type P = byte) (input P a, output P y);
  Box #(P) b;
  assign y = a;
endmodule
