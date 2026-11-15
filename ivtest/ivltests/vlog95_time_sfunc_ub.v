// Verify invalid $bitstoreal width in continuous-assign .sfunc reports a clean
// VPI error instead of aborting on null userdata / format assertion.
module top;
  wire real r;
  reg [8:0] bad_bits = 9'd0;
  assign r = $bitstoreal(bad_bits);
  initial #1 $display("%g", r);
endmodule
