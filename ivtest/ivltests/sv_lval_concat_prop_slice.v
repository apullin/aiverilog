// Verify l-value concatenations containing class properties, packed-struct
// property slices, nested class properties, and queue/darray elements in
// arbitrary positions (MSB, middle, LSB) and mixed 2-state/4-state contexts.

typedef struct packed {
  logic [3:0] hi;
  bit   [3:0] lo;
} pair8_t;

class Inner;
  logic [7:0] v;
  bit   [3:0] b;
endclass

class Outer;
  pair8_t pst;
  Inner child;
  function new();
    pst = 8'h48;
    child = new();
    child.v = 8'h00;
    child.b = 4'h0;
  endfunction
endclass

module test;
  Outer o;
  Inner inner_h;
  bit [3:0] b_tgt;
  logic [3:0] l_tgt;
  logic [7:0] q[$];
  bit [7:0] da[];

  initial begin
    o = new();
    inner_h = o.child;
    q.push_back(8'h11);
    da = new[2];
    da[1] = 8'h22;

    // Class property slice in MSB position, 2-state var in LSB position
    {o.pst.hi, b_tgt} = 8'h5a ^ 8'h3c; // 8'h66
    if (o.pst !== 8'h68 || b_tgt !== 4'h6) begin
      $display("FAILED 1: pst=%h b_tgt=%h", o.pst, b_tgt);
      $finish;
    end

    // Nested class properties + 2-state X stripping + queue/darray elements
    {o.child.v, o.child.b, q[0][7:4], da[1], l_tgt} = {8'ha5, 4'b1xz0, 4'h9, 8'b11x0_0011, 4'b10xz};
    if (inner_h.v !== 8'ha5 || inner_h.b !== 4'b1000 || q[0] !== 8'h91 ||
        da[1] !== 8'b1100_0011 || l_tgt !== 4'b10xz) begin
      $display("FAILED 2: v=%h b=%b q0=%h da1=%b lt=%b",
               inner_h.v, inner_h.b, q[0], da[1], l_tgt);
      $finish;
    end

    $display("PASSED");
  end
endmodule
