// Verify const / const ref enforcement across class properties, mutating
// queue/darray methods, $cast, extern method prototypes/constructors, and
// virtual method overrides (including queue/darray parameter types).

typedef enum int { E0 = 0, E1 = 1 } e_t;

class Base;
  const int kc = 42;
  extern function new(int a);
  extern task ext_ref(const ref int x);
  virtual task v_ref(const ref int x, int q[$]);
  endtask
endclass

function Base::new(string a); // mismatched extern constructor port type
endfunction

task Base::ext_ref(ref int x); // const ref vs ref mismatch
  x = 1;
endtask

class Sub extends Base;
  function new();
    super.new("x");
  endfunction
  virtual task v_ref(ref int x, string q[$]); // const ref + queue elem mismatch
    x = 2;
  endtask
endclass

module test;
  task automatic take_ref(ref int rx);
    rx = 99;
  endtask

  task automatic bad_const_ops(const ref int cq[$], const ref e_t ce);
    cq.push_back(7);
    void'(cq.pop_front());
    cq.delete();
    void'($cast(ce, 1));
  endtask

  Base b;
  initial begin
    take_ref(b.kc);
  end
endmodule
