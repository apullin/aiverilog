// A local undriven net may still be referenced by a synthesized array alias.
module a(output logic b [2:1]);
  assign b = '{1'b1, 1'bz};

  initial begin
    #1;
    if (b[2] === 1'b1 && b[1] === 1'bz)
      $display("PASSED");
    else
      $display("FAILED: b[2]=%b b[1]=%b", b[2], b[1]);
  end
endmodule
