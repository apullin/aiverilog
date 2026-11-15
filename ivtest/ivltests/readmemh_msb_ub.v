// Verify $readmemh handles MSB hex digits >= 8 (bits [31:28] and wide words)
// without signed 32-bit left-shift undefined behavior.
module top;
  logic [63:0] mem [0:1];
  integer fd;
  initial begin
    fd = $fopen("work/readmemh_msb_ub.hex", "w");
    $fdisplay(fd, "f89abcde_deadbeef");
    $fdisplay(fd, "80000000_90000001");
    $fclose(fd);
    $readmemh("work/readmemh_msb_ub.hex", mem);
    if (mem[0] !== 64'hf89abcde_deadbeef || mem[1] !== 64'h80000000_90000001) begin
      $display("FAILED: m0=%h m1=%h", mem[0], mem[1]);
      $finish;
    end
    $display("PASSED");
  end
endmodule
