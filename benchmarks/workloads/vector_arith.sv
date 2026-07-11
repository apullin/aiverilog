module vector_arith_bench;
  localparam integer ITERATIONS = 400000;

  reg [255:0] a;
  reg [255:0] b;
  reg [255:0] accum;
  reg [511:0] product;
  reg [63:0] narrow;
  integer idx;
  integer converted;
  real scaled;

  initial begin
    a = 256'h243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    b = 256'h452821e638d01377be5466cf34e90c6cc0ac29b7c97c50dd3f84d5b5b5470917;
    accum = 256'h9e3779b97f4a7c15f39cc0605cedc8351082276bf3a27251f86c6a11d0c18e95;
    narrow = 64'h6a09e667f3bcc909;
    converted = 0;

    for (idx = 0; idx < ITERATIONS; idx = idx + 1) begin
      a = {a[246:0], a[255:247]} ^ (b >> 13) ^ idx;
      b = {b[238:0], b[255:239]} + a + 256'h517cc1b727220a95;
      product = a * b;
      accum = accum + product[255:0] + product[511:256];
      accum = (accum << 9) | (accum >> 247);
      narrow = narrow * 64'h5851f42d4c957f2d + accum[63:0];

      if ((idx & 63) == 0) begin
        accum = accum / (narrow[15:0] | 16'h1);
        scaled = $itor(narrow[31:0]) / 1024.0;
        converted = converted ^ $rtoi(scaled);
      end
    end

    $display("vector_arith iterations=%0d checksum=%064x/%016x/%08x",
             ITERATIONS, accum, narrow, converted);
    $finish(0);
  end
endmodule
