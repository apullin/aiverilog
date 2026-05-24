// Test for GitHub issue #455
// Under `default_nettype none', a port declaration with no explicit
// net type (i.e. relying on an implicit net) is illegal per IEEE
// 1364-2005 §3.5 / IEEE 1800-2017 §6.10. iverilog must report an
// elaboration error.

`default_nettype none

module m (input clk);
endmodule
