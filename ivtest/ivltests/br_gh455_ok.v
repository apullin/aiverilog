// A separate net declaration makes a non-ANSI port explicit even when
// `default_nettype none was active at the incomplete port declaration.
`default_nettype none

module split_declaration(clk);
  input clk;
  wire clk;
endmodule

module explicit_ansi(input wire clk);
endmodule

module explicit_variable(input var logic clk);
endmodule

module test;
  initial $display("PASSED");
endmodule
