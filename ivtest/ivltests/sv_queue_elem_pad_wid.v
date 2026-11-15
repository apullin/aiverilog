// Verify widening a queue or dynamic-array element (via pad_to_width)
// preserves the element's base type in NetESelect::expr_type().
module top;
  bit [7:0] q[$];
  bit [7:0] da[];
  int r1, r2;
  initial begin
    q.push_back(8'd5);
    da = new[1];
    da[0] = 8'd12;
    r1 = (q[0] inside { [$:0], 32'd5 });
    r2 = (da[0] + 32'd8);
    if (r1 !== 1 || r2 !== 20) begin
      $display("FAILED: r1=%0d r2=%0d", r1, r2);
      $finish;
    end
    $display("PASSED");
  end
endmodule
