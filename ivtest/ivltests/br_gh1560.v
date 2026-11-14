// Regression test for upstream #1560:
// Reading and assigning members (including nested structs and bit/part-selects)
// of a packed-struct class property, as well as bit/part-selects of vector
// class properties.
module top;
  typedef struct packed {
    logic [7:0] hi;
    logic [7:0] lo;
  } inner_t;

  typedef struct packed {
    logic [7:0] x;
    inner_t     sub;
  } pt_t;

  class C;
    pt_t         pt;
    logic [15:0] vec;
  endclass

  initial begin
    C c;
    int idx;
    c = new();

    c.pt = 24'h11_22_33;
    if (c.pt.x !== 8'h11 || c.pt.sub.hi !== 8'h22 || c.pt.sub.lo !== 8'h33) begin
      $display("FAILED initial struct read: %h %h %h",
               c.pt.x, c.pt.sub.hi, c.pt.sub.lo);
      $finish;
    end

    c.pt.x = 8'hbb;
    c.pt.sub.lo = 8'hee;
    c.pt.sub.hi[7:4] = 4'ha;
    if (c.pt !== 24'hbb_a2_ee || c.pt.x !== 8'hbb ||
        c.pt.sub.hi !== 8'ha2 || c.pt.sub.lo !== 8'hee) begin
      $display("FAILED struct member write: pt=%h", c.pt);
      $finish;
    end

    // Compound assignment on packed-struct class property member
    c.pt.x += 8'h05;
    if (c.pt.x !== 8'hc0) begin
      $display("FAILED compound struct member write: %h", c.pt.x);
      $finish;
    end

    // Bit-select and part-select writes on vector class property
    c.vec = 16'h0000;
    c.vec[11:8] = 4'hd;
    idx = 3;
    c.vec[idx] = 1'b1;
    c.vec[12 +: 4] = 4'hf;
    if (c.vec !== 16'hfd08) begin
      $display("FAILED vec property slices: %h", c.vec);
      $finish;
    end

    $display("PASSED");
  end
endmodule
