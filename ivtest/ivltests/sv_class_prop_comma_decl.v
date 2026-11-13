// Regression test for GitHub #1586: comma-separated class property
// declarations inside a module must share their pform data_type_t
// without double-freeing during module destruction.
module sv_class_prop_comma_decl;
  typedef logic [15:0] word_t;

  class K;
    int a = 10, b = 20, c = 30;
    word_t x = 16'h1234, y = 16'h5678;
    K next, prev[2];
    static int s0 = 3, s1 = 4;
  endclass

  initial begin
    K obj;
    obj = new;
    if (obj.a !== 10 || obj.b !== 20 || obj.c !== 30) begin
      $display("FAILED: %0d %0d %0d", obj.a, obj.b, obj.c);
      $finish;
    end
    if (obj.x !== 16'h1234 || obj.y !== 16'h5678) begin
      $display("FAILED: %h %h", obj.x, obj.y);
      $finish;
    end
    if (obj.s0 + obj.s1 !== 7) begin
      $display("FAILED: static %0d %0d", obj.s0, obj.s1);
      $finish;
    end
    $display("PASSED");
  end
endmodule
