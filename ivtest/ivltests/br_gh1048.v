module test;

typedef enum logic [1:0] { STATE_A = 2'b00, STATE_B = 2'b11 } state_t;

state_t state_a = STATE_A;
state_t state_b = STATE_B;
state_t result;
integer failed = 0;

function automatic state_t choose(input logic select);
  choose = select ? STATE_A : STATE_B;
endfunction

task automatic check_arg(input state_t value, input logic [1:0] expected);
  if (value !== expected)
    failed = 1;
endtask

task automatic check(input logic select, input logic [1:0] expected);
  result = select ? STATE_A : STATE_B;
  if (result !== expected)
    failed = 1;

  result = select ? state_a : state_b;
  if (result !== expected)
    failed = 1;

  if (choose(select) !== expected)
    failed = 1;

  check_arg(select ? STATE_A : STATE_B, expected);
endtask

initial begin
  check(1'b0, 2'b11);
  check(1'b1, 2'b00);

  // Four-state selectors blend values without changing the enum type.
  check(1'bx, 2'bxx);
  check(1'bz, 2'bxx);

  result = 1'bx ? STATE_A : STATE_B;
  if (result !== 2'bxx)
    failed = 1;

  result = 1'bz ? STATE_A : STATE_B;
  if (result !== 2'bxx)
    failed = 1;

  if (failed)
    $display("FAILED");
  else
    $display("PASSED");
end

endmodule
