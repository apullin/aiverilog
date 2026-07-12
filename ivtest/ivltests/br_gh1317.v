module test;
  logic clk = 0;
  logic value;

  always #1 clk = !clk;

  initial value = 1'b0;

  always_ff @(posedge clk)
    value <= 1'b1;
endmodule
