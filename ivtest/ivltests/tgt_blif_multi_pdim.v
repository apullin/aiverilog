// Verify that -tblif handles multi-dimensional packed vector ports and nets.

module top(input wire [1:0][3:0] a, input wire [1:0][3:0] b, output wire [1:0][3:0] y);
  assign y = a ^ b;
endmodule
