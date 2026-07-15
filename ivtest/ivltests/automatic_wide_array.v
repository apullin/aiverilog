module automatic_wide_array;

task automatic check;
input integer step;
input [127:0] seed;

reg [127:0] array [1:0];

begin
  if (array[0] !== {128{1'bx}} || array[1] !== {128{1'bx}})
    $display("FAILED: automatic array was not reset");

  array[0] = seed;
  array[1] = ~seed;
  #step;

  if (array[0] !== seed || array[1] !== ~seed)
    $display("FAILED: automatic array context was not isolated");
end
endtask

initial begin
  fork
    check(1, 128'h0123456789abcdef_fedcba9876543210);
    check(2, 128'h1111222233334444_aaaabbbbccccdddd);
  join

  // Exercise reset after a released context is reused.
  check(1, 128'hdeadbeef01234567_89abcdef76543210);
  $display("PASSED");
end

endmodule
