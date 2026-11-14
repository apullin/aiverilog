// Regression test for upstream #1611:
// Compound assignments (lhs op= rhs) must evaluate arithmetic/bitwise ops at
// max($bits(lhs), $bits(rhs)) with combined (lhs && rhs) signedness, and
// evaluate shift amounts as self-determined, both at runtime and in constant
// functions.
module top;
  class box_t;
    byte b;
  endclass

  function automatic logic [7:0] cfunc_div();
    logic [7:0] x = 8'd200;
    x /= 16'd300;
    return x;
  endfunction

  localparam logic [7:0] CP = cfunc_div();

  initial begin
    logic [7:0] u8;
    bit   [7:0] b8;
    byte        s8;
    int         q[$];
    box_t       c;

    // Wider RHS division and modulo on 4-state and 2-state narrow LHS
    u8 = 8'd200;
    u8 /= 16'd300;
    if (u8 !== 8'd0 || CP !== 8'd0) begin
      $display("FAILED u8 /= 16'd300: u8=%0d CP=%0d", u8, CP);
      $finish;
    end

    u8 = 8'd200;
    u8 %= 16'd300;
    if (u8 !== 8'd200) begin
      $display("FAILED u8 %%= 16'd300: %0d", u8);
      $finish;
    end

    b8 = 8'd200;
    b8 /= 16'd300;
    if (b8 !== 8'd0) begin
      $display("FAILED b8 /= 16'd300: %0d", b8);
      $finish;
    end

    // Signed LHS + signed wider RHS vs signed LHS + unsigned wider RHS
    s8 = -8'sd100;
    s8 /= 16'sd20;
    if (s8 !== -8'sd5) begin
      $display("FAILED signed /= signed: %0d", s8);
      $finish;
    end

    s8 = -8'sd100;
    s8 /= 16'd20; // mixed sign -> unsigned 16'h009c / 16'd20 = 7
    if (s8 !== 8'sd7) begin
      $display("FAILED signed /= unsigned: %0d", s8);
      $finish;
    end

    // Self-determined wide shift amount (9'd256 must NOT truncate to 8'd0!)
    u8 = 8'hff;
    u8 >>= 9'd256;
    if (u8 !== 8'd0) begin
      $display("FAILED u8 >>= 9'd256: %h", u8);
      $finish;
    end

    // Queue element and class property compound assignments with wider RHS
    q.push_back(200);
    q[0] /= 64'd300;
    if (q[0] !== 0) begin
      $display("FAILED q[0] /= 64'd300: %0d", q[0]);
      $finish;
    end

    c = new();
    c.b = -8'sd100;
    c.b /= 16'sd25;
    if (c.b !== -8'sd4) begin
      $display("FAILED c.b /= 16'sd25: %0d", c.b);
      $finish;
    end

    $display("PASSED");
  end
endmodule
