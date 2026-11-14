// Regression test for upstream #1545:
// tranif0 and rtranif0 #(turn_on, turn_off) delays must apply turn_on when
// control falls to 0 and turn_off when control rises to 1.
`timescale 1ns/1ns
module top;
  reg drv = 1'b1;
  reg ctrl = 1'b1;
  wire a, out_tran, out_rtran;

  assign a = drv;
  tranif0  #(10, 20) g1(out_tran,  a, ctrl);
  rtranif0 #(10, 20) g2(out_rtran, a, ctrl);

  initial begin
    #25;
    // Initially ctrl=1 -> both switches off (HiZ)
    if (out_tran !== 1'bz || out_rtran !== 1'bz) begin
      $display("FAILED initial: tran=%b rtran=%b", out_tran, out_rtran);
      $finish;
    end

    // Fall ctrl 1 -> 0: turn-on delay is 10
    ctrl = 1'b0;
    #9;
    if (out_tran !== 1'bz || out_rtran !== 1'bz) begin
      $display("FAILED early turn-on at +9: tran=%b rtran=%b", out_tran, out_rtran);
      $finish;
    end
    #2;
    if (out_tran !== 1'b1 || out_rtran !== 1'b1) begin
      $display("FAILED turn-on at +11: tran=%b rtran=%b", out_tran, out_rtran);
      $finish;
    end

    // Rise ctrl 0 -> 1: turn-off delay is 20
    ctrl = 1'b1;
    #19;
    if (out_tran !== 1'b1 || out_rtran !== 1'b1) begin
      $display("FAILED early turn-off at +19: tran=%b rtran=%b", out_tran, out_rtran);
      $finish;
    end
    #2;
    if (out_tran !== 1'bz || out_rtran !== 1'bz) begin
      $display("FAILED turn-off at +21: tran=%b rtran=%b", out_tran, out_rtran);
      $finish;
    end

    $display("PASSED");
  end
endmodule
