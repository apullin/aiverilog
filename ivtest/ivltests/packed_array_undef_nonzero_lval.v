// Verify that procedural l-value selects with an undefined ('x) index on
// multi-dimensional packed arrays whose index range does not include 0
// compile and leave elements unchanged (no-op write).

module test;
  reg [5:4][3:0] hi_vec;
  reg [-1:-1][3:0] neg_vec;
  reg [1:0][5:4][3:0] nested_vec;

  initial begin
    hi_vec = 8'ha5;
    neg_vec = 4'h9;
    nested_vec = 16'h1234;

    hi_vec[1'bx] = 4'hf;
    neg_vec[1'bx] = 4'h0;
    nested_vec[99][1'bx] = 4'hf;

    if (hi_vec !== 8'ha5 || neg_vec !== 4'h9 || nested_vec !== 16'h1234) begin
      $display("FAILED: hi=%h neg=%h nested=%h", hi_vec, neg_vec, nested_vec);
      $finish;
    end
    $display("PASSED");
  end
endmodule
