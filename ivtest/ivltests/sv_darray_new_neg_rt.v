module top;
  int n = -5;
  int d[];
  initial begin
    d = new[n];
    $display("FAILED");
  end
endmodule
