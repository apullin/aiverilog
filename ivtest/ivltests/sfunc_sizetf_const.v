// Verify that vpiSizedFunc system functions ($realtobits, $shortrealtobits)
// register and return their expected widths cleanly under function-type UBSan.
module sfunc_sizetf_const;
  wire [63:0] rbits = $realtobits(1.5);
  wire [31:0] sbits = $shortrealtobits(1.5);

  initial begin
    #1;
    if ($bits(rbits) !== 64 || rbits !== 64'h3ff80000_00000000) begin
      $display("FAILED: rbits=%h", rbits);
      $finish;
    end
    if ($bits(sbits) !== 32 || sbits !== 32'h3fc00000) begin
      $display("FAILED: sbits=%h", sbits);
      $finish;
    end
    $display("PASSED");
  end
endmodule
