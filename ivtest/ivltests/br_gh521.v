module test;
  logic [3:0][3:0] down;
  logic [0:3][0:3] up;
  logic [-2:1][5:2] offset;
  logic [3:0][3:0] words [0:1];
  integer i;
  integer j;
  integer k;
  reg failed = 0;

  initial begin
    down = '0;
    for (i = 0; i < 4; i = i + 1)
      down[i][3] = 1'b1;
    if (down !== 16'h8888) begin
      $display("FAILED: variable outer index: %h", down);
      failed = 1;
    end

    down = '0;
    for (i = 0; i < 4; i = i + 1)
      for (j = 0; j < 4; j = j + 1)
        down[i][j] = (i == j);
    if (down !== 16'h8421) begin
      $display("FAILED: two variable indices: %h", down);
      failed = 1;
    end

    up = '0;
    for (i = 0; i < 4; i = i + 1)
      up[i][3-i] = 1'b1;
    if (up !== 16'h1248) begin
      $display("FAILED: ascending ranges: %h", up);
      failed = 1;
    end

    offset = '0;
    for (i = -2; i <= 1; i = i + 1)
      for (j = 2; j <= 5; j = j + 1)
        offset[i][j] = ((i + 2) == (j - 2));
    if (offset !== 16'h1248) begin
      $display("FAILED: offset ranges: %h", offset);
      failed = 1;
    end

    words[0] = '0;
    words[1] = '0;
    for (k = 0; k < 2; k = k + 1)
      for (i = 0; i < 4; i = i + 1)
        words[k][i][k] = 1'b1;
    if (words[0] !== 16'h1111 || words[1] !== 16'h2222) begin
      $display("FAILED: unpacked and packed indices: %h %h",
               words[0], words[1]);
      failed = 1;
    end

    if (!failed)
      $display("PASSED");
  end
endmodule
