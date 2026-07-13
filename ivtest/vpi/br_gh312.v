module test;
  logic src = 0;
  logic clk = 0;
  logic logic_a, logic_b, logic_c;
  logic signed [3:0] signed_a;
  logic [3:0] partial;
  logic [1:0] rhs = 2'b10;
  bit bit_a;
  wire logic net_a;

  assign logic_a = src;
  assign signed_a = {4{src}};
  assign partial[2:1] = rhs;
  assign bit_a = src;
  assign net_a = src;
  always @* logic_b = src;
  always @(posedge clk) logic_c <= src;

  initial begin
    #1;
    $check_vpi_types;
    #0;
    if (partial !== 4'b0101)
      $display("FAILED: VPI deposit produced %b", partial);
    else
      $display("PASSED");
  end
endmodule
