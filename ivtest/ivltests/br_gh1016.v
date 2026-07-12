module test;
  integer failed = 0;
  integer disabled_block_ran = 0;

  function automatic integer find_first;
    integer result;
    result = -1;
    for (integer i = 0; i < 4; i = i + 1) begin : priority_loop
      if (i == 1) begin
        result = i;
        break;
      end
    end
    return result;
  endfunction

  initial begin : loop_tests
    integer count;
    integer sum;

    count = 0;
    for (integer i = 0; i < 4; i = i + 1) begin : named_break
      count = count + 1;
      if (i == 1)
        break;
    end
    if (count != 2) begin
      $display("FAILED: named break count %0d", count);
      failed = 1;
    end

    sum = 0;
    for (integer i = 0; i < 4; i = i + 1) begin : named_continue
      if (i == 1)
        continue;
      sum = sum + i;
    end
    if (sum != 5) begin
      $display("FAILED: named continue sum %0d", sum);
      failed = 1;
    end

    count = 0;
    for (integer i = 0; i < 4; i = i + 1) begin
      integer local_i;
      local_i = i;
      count = count + 1;
      if (local_i == 1)
        break;
    end
    if (count != 2) begin
      $display("FAILED: declaration block break count %0d", count);
      failed = 1;
    end

    if (find_first() != 1) begin
      $display("FAILED: function returned %0d", find_first());
      failed = 1;
    end
  end

  initial begin : disabled_block
    #5 disabled_block_ran = 1;
  end

  initial begin
    #1 disable disabled_block;
    #5;
    if (disabled_block_ran) begin
      $display("FAILED: explicit disable did not stop named block");
      failed = 1;
    end
    if (!failed)
      $display("PASSED");
  end
endmodule
