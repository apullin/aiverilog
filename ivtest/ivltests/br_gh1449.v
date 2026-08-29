module top;
  typedef logic [9:0] exp_t [0:7];

  function automatic exp_t build_exp();
    exp_t t;
    logic [9:0] a = 10'd1;
    for (int i = 0; i < 8; i++) begin
      t[i] = a;
      a = a + 10'd1;
    end
    return t;
  endfunction

  localparam exp_t EXP = build_exp();

  initial begin
    $display("%0d", EXP[3]);
    $finish;
  end
endmodule
