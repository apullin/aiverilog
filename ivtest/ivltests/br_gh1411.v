module main;
  reg [63:0] wide;
  reg [32:0] narrow33;
  reg [3:0] narrow4;
  integer scratch;
  integer errors = 0;

  initial begin
    wide = 64'b0;
    narrow33 = {33{1'b1}};
    narrow33[0] = 1'b0;
    narrow4 = 4'b1110;

    scratch = $countones(~wide);
    if ($countones(~narrow4) != 1) errors = errors + 1;

    scratch = $countones(~wide);
    if ($countones(~narrow33) != 1) errors = errors + 1;

    scratch = $countones(~wide);
    if (!$onehot(~narrow4)) errors = errors + 1;

    scratch = $countones(~wide);
    if (!$onehot0(~narrow33)) errors = errors + 1;

    wide = {64{1'bx}};
    scratch = $isunknown(~wide);
    if ($isunknown(~narrow4)) errors = errors + 1;

    if (errors == 0)
      $display("PASSED");
    else
      $display("FAILED: %0d errors", errors);
  end
endmodule
