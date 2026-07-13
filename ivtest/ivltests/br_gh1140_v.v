module test;
  parameter X = 4'b00x1;
  parameter Z = 4'b00z1;

  reg [X:0] packed_msb;
  reg [0:Z] packed_lsb;
  reg unpacked_msb [X:0];
  reg unpacked_lsb [0:Z];

  initial begin
    packed_msb = 1'b1;
    packed_lsb = 1'b1;
    unpacked_msb[0] = 1'b1;
    unpacked_lsb[0] = 1'b1;
    if (packed_msb !== 1'b1 || packed_lsb !== 1'b1 ||
        unpacked_msb[0] !== 1'b1 || unpacked_lsb[0] !== 1'b1)
      $display("FAILED");
    else
      $display("PASSED");
  end
endmodule
