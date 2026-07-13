module test;
  logic clk = 0;
  logic [7:0] address;
  logic [31:0] write_data;
  logic [1:0][1:0][7:0] mem[0:1];
  logic [0:1][2:3][7:0] ascending;
  logic [-1:-2][5:4][7:0] offset;
  integer word;
  integer half;
  integer byte_index;
  integer i;
  integer j;
  reg failed = 0;

  always_ff @(posedge clk)
    mem[address[7:2]][address[1]][address[0]] <= write_data[31:24];

  initial begin
    mem[0] = '0;
    mem[1] = '0;
    for (word = 0; word < 2; word = word + 1)
      for (half = 0; half < 2; half = half + 1)
        for (byte_index = 0; byte_index < 2;
             byte_index = byte_index + 1) begin
          address = (word << 2) | (half << 1) | byte_index;
          write_data = (8'h80 + word*4 + half*2 + byte_index) << 24;
          #1 clk = 1;
          #1 clk = 0;
        end
    #1;
    if (mem[0] !== 32'h83828180 || mem[1] !== 32'h87868584) begin
      $display("FAILED: descending slices: %h %h", mem[0], mem[1]);
      failed = 1;
    end
    for (word = 0; word < 2; word = word + 1)
      for (half = 0; half < 2; half = half + 1)
        for (byte_index = 0; byte_index < 2;
             byte_index = byte_index + 1)
          if (mem[word][half][byte_index] !==
              8'h80 + word*4 + half*2 + byte_index) begin
            $display("FAILED: descending read: %h", mem[word]);
            failed = 1;
          end

    ascending = '0;
    for (i = 0; i <= 1; i = i + 1)
      for (j = 2; j <= 3; j = j + 1)
        ascending[i][j] = 8'haa + i*2 + (j-2);
    if (ascending !== 32'haaabacad) begin
      $display("FAILED: ascending slices: %h", ascending);
      failed = 1;
    end
    for (i = 0; i <= 1; i = i + 1)
      for (j = 2; j <= 3; j = j + 1)
        if (ascending[i][j] !== 8'haa + i*2 + (j-2)) begin
          $display("FAILED: ascending read: %h", ascending);
          failed = 1;
        end

    offset = '0;
    for (i = -1; i >= -2; i = i - 1)
      for (j = 5; j >= 4; j = j - 1)
        offset[i][j] = 8'h11 + (-1-i)*2 + (5-j);
    if (offset !== 32'h11121314) begin
      $display("FAILED: offset slices: %h", offset);
      failed = 1;
    end
    for (i = -1; i >= -2; i = i - 1)
      for (j = 5; j >= 4; j = j - 1)
        if (offset[i][j] !== 8'h11 + (-1-i)*2 + (5-j)) begin
          $display("FAILED: offset read: %h", offset);
          failed = 1;
        end

    if (!failed)
      $display("PASSED");
  end
endmodule
