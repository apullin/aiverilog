// Verify -tsizer succeeds on modules declaring classes without duplicate
// child-scope assertion failure in ivl_scope_childs().
module top;
  class C;
    int x;
    function int get_x();
      return x;
    endfunction
  endclass
  input wire a;
  output wire y;
  assign y = ~a;
endmodule
