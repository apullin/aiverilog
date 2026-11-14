// Regression test for upstream #1759:
// Dynamic $cast(enum_dest, expr) in both function and task forms (2-state and
// 4-state enums, signed/unsigned width checks, class enum properties, array
// elements, and constant functions).
module top;
  typedef enum logic [1:0] {
    S_IDLE = 2'b00,
    S_RUN  = 2'b01,
    S_ERR  = 2'b1x
  } state4_e;

  typedef enum byte {
    B_NEG = -8'sd5,
    B_POS =  8'sd7
  } sbyte_e;

  class holder_c;
    state4_e st;
  endclass

  function automatic state4_e parse_state(input int code);
    state4_e tmp;
    if (!$cast(tmp, code))
      tmp = S_IDLE;
    return tmp;
  endfunction

  localparam state4_e LP_OK   = parse_state(1);
  localparam state4_e LP_FALL = parse_state(3);

  state4_e st, st_arr[2];
  sbyte_e  sb;
  holder_c h;

  initial begin
    int ok;

    if (LP_OK !== S_RUN || LP_FALL !== S_IDLE) begin
      $display("FAILED cfunc enum $cast: %0d %0d", LP_OK, LP_FALL);
      $finish;
    end

    st = S_IDLE;
    ok = $cast(st, 1);
    if (ok !== 1 || st !== S_RUN) begin
      $display("FAILED valid $cast(st, 1): ok=%0d st=%b", ok, st);
      $finish;
    end

    // Wider value 4 (32'b100) must NOT truncate to 2'b00 and falsely match!
    ok = $cast(st, 32'd4);
    if (ok !== 0 || st !== S_RUN) begin
      $display("FAILED out-of-range wider int $cast: ok=%0d st=%b", ok, st);
      $finish;
    end

    // 4-state member exact match (2'b1x) vs non-member (2'b10)
    ok = $cast(st, 2'b10);
    if (ok !== 0 || st !== S_RUN) begin
      $display("FAILED non-member 2'b10: ok=%0d st=%b", ok, st);
      $finish;
    end
    ok = $cast(st, 2'b1x);
    if (ok !== 1 || st !== S_ERR) begin
      $display("FAILED 4-state member 2'b1x: ok=%0d st=%b", ok, st);
      $finish;
    end

    // Signed enum negative match vs unsigned 251 (8'hfb != -5!)
    sb = B_POS;
    ok = $cast(sb, -32'sd5);
    if (ok !== 1 || sb !== B_NEG) begin
      $display("FAILED signed negative $cast: ok=%0d sb=%0d", ok, sb);
      $finish;
    end
    ok = $cast(sb, 16'd251);
    if (ok !== 0 || sb !== B_NEG) begin
      $display("FAILED unsigned 251 into signed byte enum: ok=%0d sb=%0d", ok, sb);
      $finish;
    end

    // Unpacked array element and class property destinations + task form
    st_arr[1] = S_IDLE;
    $cast(st_arr[1], 1);
    if (st_arr[1] !== S_RUN) begin
      $display("FAILED array element enum $cast");
      $finish;
    end

    h = new();
    h.st = S_IDLE;
    ok = $cast(h.st, 1);
    if (ok !== 1 || h.st !== S_RUN) begin
      $display("FAILED class property enum $cast");
      $finish;
    end

    $display("PASSED");
  end
endmodule
