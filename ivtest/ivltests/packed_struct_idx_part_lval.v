// Verify constant +: and -: indexed part-select l-values on ascending and
// descending packed struct and union members.
module top;
  typedef struct packed {
    logic [15:0] hi;
    logic [0:15] lo_asc;
  } pair_t;

  typedef union packed {
    pair_t p;
    logic [31:0] raw;
  } uni_t;

  uni_t u;
  initial begin
    u.raw = 32'h1234_5678;
    u.p.hi[4 +: 4]     = 4'ha;
    u.p.hi[15 -: 4]    = 4'h9;
    u.p.lo_asc[4 +: 4] = 4'hf;
    u.p.lo_asc[3 -: 4] = 4'hc;
    if (u.raw !== 32'h92a4_cf78) begin
      $display("FAILED: raw=%h", u.raw);
      $finish;
    end
    $display("PASSED");
  end
endmodule
