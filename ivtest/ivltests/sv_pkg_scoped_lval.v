// Verify package-qualified l-values in blocking, compound, inc/dec,
// nonblocking, slice, array, and continuous assignments (Upstream #1827).
package p;
  int hits;
  logic [7:0] vec;
  int arr[4];
  logic [3:0] w;
endpackage

module m;
  logic [3:0] drv = 4'h9;
  assign p::w = drv;

  initial begin
    automatic int idx = 2;
    p::hits = 3;
    p::hits += 4;
    p::hits++;
    ++p::hits;
    p::vec = 8'h00;
    p::vec[7:4] = 4'ha;
    {p::vec[3:2], p::vec[1:0]} = 4'h5;
    p::arr[idx] <= 77;
    #1;
    if (p::hits !== 9) begin $display("FAILED hits=%0d", p::hits); $finish; end
    if (p::vec !== 8'ha5) begin $display("FAILED vec=%h", p::vec); $finish; end
    if (p::arr[2] !== 77) begin $display("FAILED arr=%0d", p::arr[2]); $finish; end
    if (p::w !== 4'h9) begin $display("FAILED w=%h", p::w); $finish; end
    $display("PASSED");
  end
endmodule
