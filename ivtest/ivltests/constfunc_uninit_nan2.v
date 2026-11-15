// Verify constant-function compound assignments on default-initialized locals
// and 2-state real NaN/Inf / X/Z conversions match runtime evaluation.
module top;
  function automatic bit [15:0] fn_check(input logic [7:0] x);
    bit [7:0] b_acc;
    logic [3:0] l_acc;
    real r_acc;
    bit nan_b, inf_b;
    begin
      b_acc |= x;
      l_acc &= 4'h0;
      r_acc += 3.0;
      nan_b = bit'(0.0 / 0.0);
      inf_b = bit'(1.0 / 0.0);
      fn_check = {b_acc, l_acc, 2'(int'(r_acc)), nan_b, inf_b};
    end
  endfunction

  localparam bit [15:0] P = fn_check(8'h5x);
  bit [15:0] rt;
  logic [7:0] rx = 8'h5x;

  initial begin
    rt = fn_check(rx);
    if (P !== 16'b0101_0000_0000_1100 || rt !== P) begin
      $display("FAILED: P=%b rt=%b", P, rt);
      $finish;
    end
    $display("PASSED");
  end
endmodule
