// Regression test for upstream #1544:
// Bit-select and variable bit-select of a strength-driven vector must
// preserve drive strength through resistive MOS switches (rnmos/rpmos).
module top;
  wire [1:0] v_weak;
  wire [1:0] v_pull;
  wire [1:0] v_supply;
  reg sel = 1'b0;
  wire out_const, out_var, out_pull, out_supply;

  assign (weak1, weak0)     v_weak   = 2'b01;
  assign (pull1, pull0)     v_pull   = 2'b01;
  assign (supply1, supply0) v_supply = 2'b10;

  // IEEE 1800-2023 Table 28-6:
  //   weak   -> medium ("Me1"/"Me0")
  //   pull   -> weak   ("We1")
  //   supply -> pull   ("Pu1")
  rnmos g1(out_const,  v_weak[0],   1'b1);
  rnmos g2(out_var,    v_weak[sel], 1'b1);
  rnmos g3(out_pull,   v_pull[0],   1'b1);
  rpmos g4(out_supply, v_supply[1], 1'b0);

  // Weak pull-down beats medium1 if and only if weak1 was reduced to medium1!
  wire contested;
  pulldown (weak0) pd(contested);
  rnmos g5(contested, v_weak[0], 1'b1);

  string s1, s2, s3, s4;

  initial begin
    #1;
    s1 = $sformatf("%v", out_const);
    s2 = $sformatf("%v", out_var);
    s3 = $sformatf("%v", out_pull);
    s4 = $sformatf("%v", out_supply);
    if (s1 != "Me1" || s2 != "Me1" || s3 != "We1" || s4 != "Pu1" || contested !== 1'b0) begin
      $display("FAILED at sel=0: s1=%s s2=%s s3=%s s4=%s contested=%b",
               s1, s2, s3, s4, contested);
      $finish;
    end

    sel = 1'b1;
    #1;
    s2 = $sformatf("%v", out_var);
    if (s2 != "Me0") begin
      $display("FAILED at sel=1: s2=%s", s2);
      $finish;
    end

    $display("PASSED");
  end
endmodule
