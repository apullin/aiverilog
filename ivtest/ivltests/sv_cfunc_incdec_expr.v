// Regression test for audit issue #162:
// Pre/post increment and decrement expressions (++x, x++, --x, x--) in
// constant functions (scalars, unpacked-array elements, loop conditions, reals).
module top;
  function automatic int calc(input int n);
    int i = 0;
    int acc = 0;
    int a[4];
    for (int k = 0; k < 4; k++) a[k] = k * 10;
    while (++i <= n) begin
      acc += (a[i & 3]++);
    end
    acc += (--i) * 100;
    acc += (a[1]--);
    acc += a[1];
    return acc;
  endfunction

  function automatic real calc_real(input real x);
    real r = x;
    real y;
    y = r++;
    y = y + (++r);
    y = y + (r--);
    y = y + (--r);
    return y;
  endfunction

  localparam int  P = calc(5);
  localparam real R = calc_real(2.5);

  initial begin
    if (P !== calc(5)) begin
      $display("FAILED int: P=%0d rt=%0d", P, calc(5));
      $finish;
    end
    if (R != calc_real(2.5)) begin
      $display("FAILED real: R=%f rt=%f", R, calc_real(2.5));
      $finish;
    end
    $display("PASSED");
  end
endmodule
