// Regression test for GitHub #1547: queue push_back, push_front, and insert
// must truncate wider non-constant expressions to the queue element width.
module sv_queue_push_wide;
  class holder_t;
    logic [7:0] cq [$];
  endclass

  logic [7:0] q [$];
  bit   [7:0] bq [$];
  int i = 32'h1234_5678;
  logic [15:0] xz = 16'haa_x5;
  holder_t h;

  initial begin
    q.push_back(i);
    q.push_front(i + 1);
    q.insert(1, i + 2);
    if (q.size() != 3 || q[0] !== 8'h79 || q[1] !== 8'h7a || q[2] !== 8'h78) begin
      $display("FAILED q: %h %h %h", q[0], q[1], q[2]);
      $finish;
    end

    bq.push_back(xz);
    if (bq[0] !== 8'h05) begin
      $display("FAILED bq: %b", bq[0]);
      $finish;
    end

    h = new;
    h.cq.push_back(i);
    h.cq.push_front(i + 3);
    h.cq.insert(1, i + 4);
    if (h.cq.size() != 3 || h.cq[0] !== 8'h7b || h.cq[1] !== 8'h7c || h.cq[2] !== 8'h78) begin
      $display("FAILED h.cq: %h %h %h", h.cq[0], h.cq[1], h.cq[2]);
      $finish;
    end

    $display("PASSED");
  end
endmodule
