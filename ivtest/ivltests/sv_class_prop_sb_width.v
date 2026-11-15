// Verify signed 2-state `bit` class properties with non-8/16/32/64 widths.
module top;
  class Box;
    bit signed [4:0]  s5;
    bit signed [39:0] s40;
    bit signed [72:0] s73;
    function new();
      s5  = -5'sd7;
      s40 = -40'sd109951162777;
      s73 = -73'sd5;
    endfunction
  endclass

  initial begin
    Box b = new();
    if (b.s5 !== -5'sd7 || b.s40 !== -40'sd109951162777 || b.s73 !== -73'sd5) begin
      $display("FAILED: s5=%0d s40=%0d s73=%0d", b.s5, b.s40, b.s73);
      $finish;
    end
    $display("PASSED");
  end
endmodule
