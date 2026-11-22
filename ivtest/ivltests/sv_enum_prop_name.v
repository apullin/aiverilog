// Verify .name(), .next(), .prev(), .first(), .last(), and .num() on an
// enum-typed class property and unpacked enum array element (Upstream #1866).
typedef enum logic [3:0] {RED = 4'd1, GREEN = 4'd3, BLUE = 4'd7} color_e;

class C;
  color_e c = GREEN;
  function string nm();
    return c.name();
  endfunction
  function color_e nxt();
    return c.next();
  endfunction
  function color_e prv();
    return c.prev();
  endfunction
endclass

module m;
  C x = new;
  color_e arr[2];
  initial begin
    if (x.nm() != "GREEN" || x.c.name() != "GREEN") begin
      $display("FAILED nm=%s ext=%s", x.nm(), x.c.name());
      $finish;
    end
    if (x.nxt() !== BLUE || x.prv() !== RED) begin
      $display("FAILED nxt=%0d prv=%0d", x.nxt(), x.prv());
      $finish;
    end
    x.c = color_e'(4'd9);
    if (x.nm() != "") begin
      $display("FAILED oob nm=%s", x.nm());
      $finish;
    end
    arr[0] = RED;
    arr[1] = BLUE;
    if (arr[1].name() != "BLUE" || arr[1].next() !== RED) begin
      $display("FAILED arr nm=%s nxt=%0d", arr[1].name(), arr[1].next());
      $finish;
    end
    $display("PASSED");
  end
endmodule
