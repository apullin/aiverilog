// Regression test for upstream #536:
// Reading and writing unpacked array slices (multi-D sub-arrays arr[i],
// 1-D range slices arr[hi:lo], indexed +:/-: slices, overlapping self-copies,
// assignment-pattern RHS, non-blocking <=, and continuous assign).
module top;
  reg  [7:0] arr1[0:7][0:1];
  reg  [7:0] arr2[0:7][0:1];
  reg  [7:0] row [1:0];       // opposite direction [1:0] vs [0:1]!

  int        v[0:5];
  int        nb[0:3];

  wire [7:0] w_mat[0:1][0:1];
  wire [7:0] w_row[0:1];
  reg  [7:0] drv0 = 8'h33, drv1 = 8'h77;
  assign w_mat[0][0] = 8'h11;
  assign w_mat[0][1] = 8'h22;
  assign w_mat[1]    = w_row;
  assign w_row       = '{drv0, drv1};

  initial begin
    int i, j;
    #1;

    // Continuous assign of unpacked sub-array
    if (w_mat[1][0] !== 8'h33 || w_mat[1][1] !== 8'h77) begin
      $display("FAILED continuous sub-array assign: %h %h",
               w_mat[1][0], w_mat[1][1]);
      $finish;
    end

    // Upstream #536 exact reproducer + dynamic index with ++ side effects
    arr2[3][0] = 8'ha5;
    arr2[3][1] = 8'h5a;
    i = 2; j = 3;
    arr1[i++] = arr2[j++];
    if (i !== 3 || j !== 4 || arr1[2][0] !== 8'ha5 || arr1[2][1] !== 8'h5a) begin
      $display("FAILED 2D sub-array slice: i=%0d j=%0d %h %h",
               i, j, arr1[2][0], arr1[2][1]);
      $finish;
    end

    // Opposite-direction 1D whole <-> 2D sub-array slice
    row = arr1[2];
    if (row[1] !== 8'ha5 || row[0] !== 8'h5a) begin
      $display("FAILED opposite-dir sub-array copy: %h %h", row[1], row[0]);
      $finish;
    end

    // 1D range slice [hi:lo], indexed +: slice, pattern RHS, and overlapping self-copy!
    v = '{10, 20, 30, 40, 50, 60};
    v[1:4] = v[0:3]; // overlapping forward shift!
    if (v[0] !== 10 || v[1] !== 10 || v[2] !== 20 ||
        v[3] !== 30 || v[4] !== 40 || v[5] !== 60) begin
      $display("FAILED overlapping slice copy: %0d %0d %0d %0d %0d %0d",
               v[0], v[1], v[2], v[3], v[4], v[5]);
      $finish;
    end

    i = 4;
    v[i +: 2] = '{99, 88};
    if (v[4] !== 99 || v[5] !== 88) begin
      $display("FAILED indexed +: pattern slice: %0d %0d", v[4], v[5]);
      $finish;
    end

    // Non-blocking unpacked slice swap
    nb = '{1, 2, 3, 4};
    nb[0:1] <= nb[2:3];
    nb[2:3] <= nb[0:1];
    #1;
    if (nb[0] !== 3 || nb[1] !== 4 || nb[2] !== 1 || nb[3] !== 2) begin
      $display("FAILED NBA slice swap: %0d %0d %0d %0d",
               nb[0], nb[1], nb[2], nb[3]);
      $finish;
    end

    $display("PASSED");
  end
endmodule
