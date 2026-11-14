// Regression test for upstream #1564 and #1587:
// Bit-select and part-select reads and writes on dynamic-array and queue
// elements (including [$], non-zero packed LSB, indexed +:/-:, and class
// queue/darray property reads).
module top;
  class C;
    logic [15:0] cq[$];
  endclass

  logic [15:0] d[];
  logic [11:4] d_off[];
  logic [15:0] q[$];
  C            c;

  initial begin
    int bit_idx;
    d = new[2];
    d[0] = 16'habcd;
    d[1] = 16'h0000;

    // R-value part-select, bit-select, and indexed part-select on darray
    if (d[0][7:0] !== 8'hcd || d[0][15:8] !== 8'hab || d[0][8 +: 4] !== 4'hb) begin
      $display("FAILED darray rval select: %h %h %h",
               d[0][7:0], d[0][15:8], d[0][8 +: 4]);
      $finish;
    end

    // L-value bit-select, part-select, indexed part-select, and += on darray
    d[1][0] = 1'b1;
    bit_idx = 5;
    d[1][bit_idx] = 1'b1;
    d[1][11:8] = 4'ha;
    d[1][12 +: 4] = 4'hf;
    d[1][3:0] += 4'd2;
    if (d[1] !== 16'hfa23) begin
      $display("FAILED darray lval select: %h", d[1]);
      $finish;
    end

    // Non-zero packed LSB on dynamic array element
    d_off = new[1];
    d_off[0] = 8'h5a;
    d_off[0][7:4] = 4'hc;
    if (d_off[0][11:8] !== 4'h5 || d_off[0][7:4] !== 4'hc || d_off[0][4] !== 1'b0) begin
      $display("FAILED d_off non-zero lsb: %h", d_off[0]);
      $finish;
    end

    // Queue element r-value and l-value selects (including [$])
    q.push_back(16'h1234);
    q.push_back(16'h5678);
    if (q[0][3:0] !== 4'h4 || q[$][15:12] !== 4'h5) begin
      $display("FAILED queue rval select: %h %h", q[0][3:0], q[$][15:12]);
      $finish;
    end
    q[0][7:4] = 4'he;
    q[$][0] = 1'b1;
    if (q[0] !== 16'h12e4 || q[1] !== 16'h5679) begin
      $display("FAILED queue lval select: %h %h", q[0], q[1]);
      $finish;
    end

    // Class queue property element slice read
    c = new();
    c.cq.push_back(16'hdead);
    if (c.cq[0][15:8] !== 8'hde || c.cq[0][3] !== 1'b1) begin
      $display("FAILED class queue rval select: %h %b", c.cq[0][15:8], c.cq[0][3]);
      $finish;
    end

    $display("PASSED");
  end
endmodule
