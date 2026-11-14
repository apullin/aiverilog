// Regression test for upstream #278:
// iverilog -F <cmdfile> resolves relative source, +incdir+, -y, and nested
// -F command-file paths relative to the command file's directory.
`include "defs.vh"

module top;
  wire [15:0] a, b;
  submod  u1(.y(a));
  leafmod u2(.y(b));

  initial begin
    #1;
    if (a !== `BR_GH278_MAGIC || b !== 16'hcafe) begin
      $display("FAILED: a=%h b=%h", a, b);
      $finish;
    end
    $display("PASSED");
  end
endmodule
