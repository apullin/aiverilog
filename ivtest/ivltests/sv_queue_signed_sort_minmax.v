// Regression test for audit issue #177:
// Signed integral queues and dynamic arrays must compare elements as signed
// in sort(), rsort(), min(), and max() (including class properties).
module top;
  class holder_t;
    int qs[$];
  endclass

  int               qi[$];
  int               ri[$];
  logic signed [11:0] dl[];
  bit   signed [11:0] db[];
  holder_t          h;

  initial begin
    qi.push_back(3);
    qi.push_back(-5);
    qi.push_back(1);
    qi.push_back(-2);

    ri = qi.min();
    if (ri.size() !== 1 || ri[0] !== -5) begin
      $display("FAILED qi.min(): size=%0d val=%0d", ri.size(), ri[0]);
      $finish;
    end

    ri = qi.max();
    if (ri.size() !== 1 || ri[0] !== 3) begin
      $display("FAILED qi.max(): size=%0d val=%0d", ri.size(), ri[0]);
      $finish;
    end

    qi.sort();
    if (qi[0] !== -5 || qi[1] !== -2 || qi[2] !== 1 || qi[3] !== 3) begin
      $display("FAILED qi.sort(): %0d %0d %0d %0d", qi[0], qi[1], qi[2], qi[3]);
      $finish;
    end

    qi.rsort();
    if (qi[0] !== 3 || qi[1] !== 1 || qi[2] !== -2 || qi[3] !== -5) begin
      $display("FAILED qi.rsort(): %0d %0d %0d %0d", qi[0], qi[1], qi[2], qi[3]);
      $finish;
    end

    // Class property signed queue
    h = new();
    h.qs.push_back(10);
    h.qs.push_back(-20);
    h.qs.push_back(0);
    ri = h.qs.min();
    if (ri[0] !== -20) begin
      $display("FAILED h.qs.min(): %0d", ri[0]);
      $finish;
    end
    h.qs.sort();
    if (h.qs[0] !== -20 || h.qs[1] !== 0 || h.qs[2] !== 10) begin
      $display("FAILED h.qs.sort(): %0d %0d %0d", h.qs[0], h.qs[1], h.qs[2]);
      $finish;
    end

    // Non-power-of-2 signed 4-state and 2-state dynamic arrays
    dl = new[3];
    dl[0] = 12'sd5; dl[1] = -12'sd9; dl[2] = 12'sd0;
    dl.sort();
    if (dl[0] !== -12'sd9 || dl[1] !== 12'sd0 || dl[2] !== 12'sd5) begin
      $display("FAILED dl.sort(): %0d %0d %0d", dl[0], dl[1], dl[2]);
      $finish;
    end

    db = new[3];
    db[0] = 12'sd7; db[1] = -12'sd3; db[2] = -12'sd12;
    db.sort();
    if (db[0] !== -12'sd12 || db[1] !== -12'sd3 || db[2] !== 12'sd7) begin
      $display("FAILED db.sort(): %0d %0d %0d", db[0], db[1], db[2]);
      $finish;
    end

    $display("PASSED");
  end
endmodule
