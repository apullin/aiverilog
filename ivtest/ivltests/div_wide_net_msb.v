// Verify >64-bit continuous-assignment unsigned/signed division and modulo
// when the dividend MSB is set and divisor is small (e.g. 1).
module top;
  logic [95:0] u_num = 96'hffff_ffff_ffff_ffff_ffff_ffff;
  logic [95:0] u_den1 = 96'd1;
  logic [95:0] u_den3 = 96'd3;
  wire  [95:0] w_div1 = u_num / u_den1;
  wire  [95:0] w_div3 = u_num / u_den3;
  wire  [95:0] w_mod3 = u_num % u_den3;

  logic signed [72:0] s_num = -73'sd123456789012345678901;
  logic signed [72:0] s_den = 73'sd1;
  wire  signed [72:0] w_sdiv = s_num / s_den;

  initial begin
    #1;
    if (w_div1 !== 96'hffff_ffff_ffff_ffff_ffff_ffff ||
        w_div3 !== 96'h5555_5555_5555_5555_5555_5555 ||
        w_mod3 !== 96'd0 ||
        w_sdiv !== s_num) begin
      $display("FAILED: d1=%h d3=%h m3=%h sd=%h", w_div1, w_div3, w_mod3, w_sdiv);
      $finish;
    end
    $display("PASSED");
  end
endmodule
