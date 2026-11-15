// Verify that extreme `line directives do not overflow signed int line
// tracking in lexor.lex, and that nested or malformed class declarations
// recover cleanly without asserting pform_cur_class == 0.

`line 2147483647 "virtual_max_line.sv" 1
// comment after INT_MAX line
module test;
  class Outer;
    class Inner;
      int x;
    endclass
  endclass
endmodule
