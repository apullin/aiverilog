// Regression test for upstream #416:
// IEEE 1800-2017 20.6.1 $typename(expr_or_type) compile-time string function.
module top;
  typedef enum logic [1:0] { IDLE = 2'd0, RUN = 2'd1 } state_e;
  typedef struct packed {
    byte        a;
    logic [3:0] b;
  } pkt_t;
  class item_c;
    int x;
  endclass

  int         my_q[$];
  int         my_qb[$:7];
  byte        my_da[];
  logic [3:0] my_ua[0:1][3:0];
  state_e     st;
  pkt_t       pk;
  item_c      it;

  localparam string T_INT   = $typename(int);
  localparam string T_UINT  = $typename(int unsigned);
  localparam string T_VEC   = $typename(logic [7:0]);
  localparam string T_Q     = $typename(my_q);
  localparam string T_QB    = $typename(my_qb);
  localparam string T_DA    = $typename(my_da);
  localparam string T_UA    = $typename(my_ua);
  localparam string T_ENUM  = $typename(state_e);
  localparam string T_PKT   = $typename(pkt_t);

  initial begin
    int side_cnt;
    string s;
    side_cnt = 10;

    if (T_INT  != "int" ||
        T_UINT != "int unsigned" ||
        T_VEC  != "logic[7:0]" ||
        T_Q    != "int$[$]" ||
        T_QB   != "int$[$:7]" ||
        T_DA   != "byte$[]" ||
        T_UA   != "logic[3:0]$[0:1]$[3:0]") begin
      $display("FAILED basic/array typenames: %s | %s | %s | %s | %s | %s | %s",
               T_INT, T_UINT, T_VEC, T_Q, T_QB, T_DA, T_UA);
      $finish;
    end

    if (T_ENUM != "enum logic[1:0]{IDLE,RUN}" || $typename(st) != T_ENUM) begin
      $display("FAILED enum typename: '%s' vs '%s'", T_ENUM, $typename(st));
      $finish;
    end

    if (T_PKT != "struct packed {byte a;logic[3:0] b;}" || $typename(pk) != T_PKT) begin
      $display("FAILED struct typename: '%s'", T_PKT);
      $finish;
    end

    if ($typename(it) != "class item_c" || $typename(item_c) != "class item_c") begin
      $display("FAILED class typename: '%s'", $typename(it));
      $finish;
    end

    if ($typename(real) != "real" || $typename(string) != "string") begin
      $display("FAILED real/string typename");
      $finish;
    end

    // Argument expression must NOT be evaluated at runtime (no side effects!)
    s = $typename(side_cnt++);
    if (side_cnt !== 10 || s != "bit signed[31:0]") begin
      $display("FAILED side effect or expr typename: side_cnt=%0d s='%s'",
               side_cnt, s);
      $finish;
    end

    $display("PASSED");
  end
endmodule
