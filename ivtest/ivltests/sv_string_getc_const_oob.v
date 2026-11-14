// Regression test for audit issue #160:
// Constant string.getc() bounds checking (64-bit index, idx == len, negative,
// X/Z, high-bit byte sign & 8-bit width) and runtime parity.
module top;
  parameter string S = "Hi\377\200";

  localparam byte C0   = S.getc(0);
  localparam byte C2   = S.getc(2);
  localparam byte C3   = S.getc(3);
  localparam byte CEQ  = S.getc(4);                  // idx == len -> 0
  localparam byte CNEG = S.getc(-1);                 // negative -> 0
  localparam byte CWID = S.getc(64'h0000_0001_0000_0005); // 64-bit -> int(5) -> 0
  localparam byte CW1  = S.getc(64'h0000_0001_0000_0001); // 64-bit -> int(1) -> 'i'
  localparam int  BITS = $bits(S.getc(0));
  localparam int  SIGNED_EXT = S.getc(2);            // byte(-1) sign-extends to -1

  string rs = S;
  string hi = "Ab\377\200Z";

  initial begin
    if (C0 !== 8'h48 || C2 !== -8'sd1 || C3 !== -8'sd128) begin
      $display("FAILED C0=%h C2=%0d C3=%0d", C0, C2, C3);
      $finish;
    end
    if (CEQ !== 8'd0 || CNEG !== 8'd0 || CWID !== 8'd0 || CW1 !== "i") begin
      $display("FAILED bounds: CEQ=%0d CNEG=%0d CWID=%0d CW1=%0d", CEQ, CNEG, CWID, CW1);
      $finish;
    end
    if (BITS !== 8 || SIGNED_EXT !== -1) begin
      $display("FAILED type: BITS=%0d SIGNED_EXT=%0d", BITS, SIGNED_EXT);
      $finish;
    end
    if (rs.getc(2) !== C2 || rs.getc(3) !== C3 || rs.getc(4) !== 8'd0 ||
        rs.getc(64'h0000_0001_0000_0001) !== CW1) begin
      $display("FAILED runtime getc mismatch");
      $finish;
    end
    if (hi.toupper() != "AB\377\200Z" || hi.tolower() != "ab\377\200z") begin
      $display("FAILED high-byte toupper/tolower");
      $finish;
    end
    $display("PASSED");
  end
endmodule
