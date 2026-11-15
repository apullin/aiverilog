// Verify that exactly 256 elaboration errors do not wrap the compiler exit
// status modulo 256 to 0 (success).

`define E1  missing_sig = 1'b0;
`define E4  `E1 `E1 `E1 `E1
`define E16 `E4 `E4 `E4 `E4
`define E64 `E16 `E16 `E16 `E16

module test;
  initial begin
    `E64 `E64 `E64 `E64
  end
endmodule
