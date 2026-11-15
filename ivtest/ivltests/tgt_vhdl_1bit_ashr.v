// Verify that -tvhdl translates 1-bit [0:0] signed arithmetic right shifts
// without out-of-bounds empty-bitstring reads or signed shift UB.

module sub(input wire [0:0] x, output wire [0:0] y);
  assign y = ~x;
endmodule

module top(
  input wire clk,
  input wire rst,
  input wire signed [0:0] a,
  input wire signed [0:0] b,
  output reg [0:0] q,
  output wire [0:0] w_alias
);
  wire [0:0] sub_y;
  sub u0(.x(a), .y(sub_y));
  assign w_alias = q;
  always @(posedge clk or posedge rst) begin
    if (rst) q <= 0;
    else q <= (a >>> b) ^ sub_y;
  end
endmodule
