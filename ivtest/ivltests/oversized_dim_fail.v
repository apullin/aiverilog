// Verify oversized packed/unpacked dimensions and infinite constant-function
// recursion fail cleanly with diagnostics instead of OOM or stack overflow.
module top;
  logic [65'h1_ffff_ffff_ffff_ffff:0] bad_vec;
  int bad_arr[2147483647][3];

  function automatic int inf_rec(input int n);
    inf_rec = (n > 0) ? inf_rec(n) + 1 : 0;
  endfunction

  localparam int BAD_P = inf_rec(1);
endmodule
