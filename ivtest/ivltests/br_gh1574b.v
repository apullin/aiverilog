// Regression test for upstream #1574 (part 2):
// Procedural copy between unpacked arrays with opposite index directions
// (1-D, 2-D, string arrays, and subroutine input arguments) must copy
// elements in left-to-right order per IEEE 1800-2023 7.6.
module top;
  logic [7:0] a[1:0];
  logic [7:0] b[0:1];
  wire  [7:0] wc[0:1];

  int m_src[1:0][0:2];
  int m_dst[0:1][2:0];

  string s_src[1:0];
  string s_dst[0:1];

  assign wc = a;

  function automatic int first_of(input logic [7:0] p[0:1]);
    return p[0];
  endfunction

  initial begin
    a[1] = 8'h11;
    a[0] = 8'h22;
    #1;
    b = a;
    if (b[0] !== 8'h11 || b[1] !== 8'h22 || b[0] !== wc[0] || b[1] !== wc[1]) begin
      $display("FAILED 1D: b[0]=%h b[1]=%h wc[0]=%h wc[1]=%h",
               b[0], b[1], wc[0], wc[1]);
      $finish;
    end

    if (first_of(a) !== 8'h11) begin
      $display("FAILED func arg: got %h", first_of(a));
      $finish;
    end

    m_src[1][0] = 10; m_src[1][1] = 11; m_src[1][2] = 12;
    m_src[0][0] = 20; m_src[0][1] = 21; m_src[0][2] = 22;
    m_dst = m_src;
    if (m_dst[0][2] !== 10 || m_dst[0][1] !== 11 || m_dst[0][0] !== 12 ||
        m_dst[1][2] !== 20 || m_dst[1][1] !== 21 || m_dst[1][0] !== 22) begin
      $display("FAILED 2D: %0d %0d %0d | %0d %0d %0d",
               m_dst[0][2], m_dst[0][1], m_dst[0][0],
               m_dst[1][2], m_dst[1][1], m_dst[1][0]);
      $finish;
    end

    s_src[1] = "left";
    s_src[0] = "right";
    s_dst = s_src;
    if (s_dst[0] != "left" || s_dst[1] != "right") begin
      $display("FAILED string: '%s' '%s'", s_dst[0], s_dst[1]);
      $finish;
    end

    $display("PASSED");
  end
endmodule
