// Verify syntax errors in specify simple paths, unclosed blocks, and malformed
// for-loop headers report errors cleanly without segfaulting or asserting.
module dut(input EN, input I, inout O);
  specify
    (EN !=?> O) = (4);
  endspecify

  initial begin
    for (var int i = 0; i < 4; i/+) begin
      int local_x;
    end
  end
endmodule
