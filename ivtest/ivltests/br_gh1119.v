// Test for GitHub issues #1119 and #1120
// The vlog95 backend used to assert when the same wire was bound to
// multiple ports of a sub-instance. Choosing either alias silently is
// unsafe when another instance uses distinct connections, so vlog95
// must report a clean unsupported-case error rather than emit incorrect
// Verilog. The normal vvp backend must still simulate this correctly.

module c (input wire first, output wire second);
  assign second = ~first;
endmodule

module b ( input wire first, output wire second );
  c c_inst ( .first(first), .second(second) );
endmodule

module test;
  reg in;
  wire out;
  wire alias_net;

  b aliased  (.first(alias_net), .second(alias_net));
  b ordinary (.first(in),        .second(out));

  initial begin
    in = 1'b0;
    #1;
    if (out !== 1'b1) begin
      $display("FAILED: out=%b for in=0", out);
      $finish;
    end
    in = 1'b1;
    #1;
    if (out !== 1'b0) begin
      $display("FAILED: out=%b for in=1", out);
      $finish;
    end
    $display("PASSED");
  end
endmodule
