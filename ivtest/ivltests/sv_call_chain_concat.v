// Regression test for GitHub #1585: chained class method calls returning
// string or packed vectors must resolve their return type in test_width
// (including inside concatenations and before function bodies elaborate).
module sv_call_chain_concat;
  class C;
    function C self();
      return this;
    endfunction
    function string nm();
      return "c";
    endfunction
    function logic [7:0] tag();
      return 8'ha5;
    endfunction
  endclass

  C co;
  string s1, s2, s3;
  logic [15:0] v;

  initial begin
    co = new;
    s1 = {co.self().nm(), "x"};
    s2 = {co.self().self().nm(), "y"};
    s3 = {make_c().nm(), "z"};
    v  = {co.self().tag(), 8'h5a};
    if (s1 != "cx" || s2 != "cy" || s3 != "cz" || v !== 16'ha55a) begin
      $display("FAILED: s1=%s s2=%s s3=%s v=%h", s1, s2, s3, v);
      $finish;
    end
    $display("PASSED");
  end

  function C make_c();
    make_c = co;
  endfunction
endmodule
