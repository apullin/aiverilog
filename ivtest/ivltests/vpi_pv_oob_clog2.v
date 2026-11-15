// Verify VPI part-select (&PV<>) vpiObjTypeVal ($clog2), partial-OOB bounds,
// and 2-state '0 out-of-bounds formatting.
module top;
  function automatic int fn_auto_clog(input logic [7:0] v);
    fn_auto_clog = $clog2(v[3:2]);
  endfunction

  bit   [3:0] b4 = 4'b1111;
  logic [3:0] l4 = 4'b1111;
  string sb, sl;
  integer c_b, c_l1, c_l2;

  initial begin
    sb   = $sformatf("%b", b4[5:2]);
    sl   = $sformatf("%b", l4[5:2]);
    c_b  = $clog2(b4[1 -: 3]);
    c_l1 = $clog2(l4[1 -: 3]);
    c_l2 = $clog2(l4[2:1]);
    if (fn_auto_clog(8'hff) !== 2 ||
        c_b !== 3 ||
        c_l1 !== 32'bx ||
        c_l2 !== 2 ||
        sb != "0011" ||
        sl != "xx11") begin
      $display("FAILED: fn=%0d cb=%0d cl1=%b cl2=%0d sb=%s sl=%s",
               fn_auto_clog(8'hff), c_b, c_l1, c_l2, sb, sl);
      $finish;
    end
    $display("PASSED");
  end
endmodule
