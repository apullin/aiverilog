// Negative test for upstream #1061: conflicting method qualifiers.
class bad_c;
  static virtual function void f1();
  endfunction

  local protected function void f2();
  endfunction

  static function new();
  endfunction
endclass

module top;
endmodule
