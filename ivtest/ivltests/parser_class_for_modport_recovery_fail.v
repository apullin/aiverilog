// Verify parser error recovery on malformed constructors, declared for-loops,
// functions, classes, and non-interface modports exits cleanly without crashing.
class bad_cls;
  int id_;
  function new(int id id_; ) = id;
  endfunction
  function int get_id();
    get_id = id_;
  endfunction
endclass

module top;
  modport bogus_mp(input a);
  initial begin
    for (int i = 0; i < 4; i + ; i++) begin
      int k;
    end
  end
endmodule
