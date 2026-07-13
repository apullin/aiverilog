module test;
  event go;
  logic value = 0;

  always @(go)
    $display("FAILED: active event ran after $finish");

  always @(go) begin
    value <= 1;
    $finish(0);
  end

  initial #1 -> go;

  final begin
    if (value !== 0)
      $display("FAILED: queued NBA ran after $finish");
    else
      $display("PASSED");
  end
endmodule
