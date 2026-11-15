// Verify packed struct/union reads in constant functions, class-property
// string/enum methods & packed slices, custom `with` iterators, and
// unpacked-array-of-objects method & property accesses.
module top;
  typedef enum logic signed [7:0] { E_NEG = -5, E_MID = 3, E_TOP = 19 } my_e_t;

  typedef struct packed {
    logic [15:0] hi;
    logic [15:0] lo;
  } pair_t;

  typedef union packed {
    pair_t p;
    logic [31:0] raw;
  } uni_t;

  class Item;
    bit signed [39:0] wide_tag;
    string label;
    my_e_t ev;
    int hits;

    function new(longint t, string s);
      wide_tag = 40'(t);
      label = s;
      ev = E_MID;
      hits = 0;
    endfunction

    virtual function int score(int k);
      return label.len() + int'(ev.first()) + int'(wide_tag[7:0]) + k;
    endfunction

    task bump(input int d);
      hits = hits + d + label.len();
    endtask
  endclass

  function automatic logic [31:0] read_union(input logic [15:0] x);
    uni_t u;
    begin
      u.p.hi = x;
      u.p.lo = ~x;
      read_union = u.raw;
    end
  endfunction

  localparam logic [31:0] P_U = read_union(16'h1234);

  Item pool [0:1];
  int qi[$];
  int qf[$];

  initial begin
    if (P_U !== 32'h1234_edcb || read_union(16'h1234) !== P_U) begin
      $display("FAILED union cfunc: P=%h", P_U);
      $finish;
    end

    pool[0] = new(-40'sd3, "alpha");
    pool[1] = new(40'sd10, "be");
    pool[0].bump(4);
    pool[1].bump(7);
    if (pool[0].score(2) !== (5 + (-5) + (-3 & 8'hff) + 2) ||
        pool[0].hits !== 9 || pool[1].hits !== 9 ||
        pool[0].label.toupper() != "ALPHA" ||
        pool[1].ev.last() !== E_TOP) begin
      $display("FAILED pool: s0=%0d h0=%0d h1=%0d",
               pool[0].score(2), pool[0].hits, pool[1].hits);
      $finish;
    end

    qi = '{ 3, 14, 7, 22, 1 };
    qf = qi.find(elem) with (elem >= 10);
    if (qf.size() !== 2 || qf[0] !== 14 || qf[1] !== 22) begin
      $display("FAILED find(elem) with: sz=%0d", qf.size());
      $finish;
    end

    $display("PASSED");
  end
endmodule
