module test;
  integer values[];
  integer index = 0;
  integer fixed_events = 0;
  integer indexed_events = 0;
  integer whole_events = 0;
  wire signed [31:0] mirror = values[2];

  always @(values[0]) fixed_events += 1;
  always @(values[index]) indexed_events += 1;
  always @(values) whole_events += 1;

  real real_values[];
  integer real_events = 0;
  always @(real_values[0]) real_events += 1;

  string string_values[];
  integer string_events = 0;
  always @(string_values[0]) string_events += 1;

  initial begin
    values = new[3]; values[0] = 1; #1;
    values[1] = 9; #1;
    values[0] = 1; #1;
    values[0] = 2; #1;
    index = 1; #1;
    values[0] = 3; #1;
    values[1] = 9; #1;
    values[1] = 10; #1;
    values[2] = 42; #1;
    if (mirror !== 42)
      $fatal(1, "continuous value is %0d", mirror);
    index = 5; #1;
    index = 0; #1;

    if (fixed_events != 3)
      $fatal(1, "fixed event count is %0d", fixed_events);
    if (indexed_events != 6)
      $fatal(1, "indexed event count is %0d", indexed_events);
    if (whole_events != 6)
      $fatal(1, "whole-array event count is %0d", whole_events);
  end

  initial begin
    real_values = new[2]; real_values[0] = 1.5; #2;
    real_values[1] = 7.0; #2;
    real_values[0] = 1.5; #2;
    real_values[0] = 2.5; #6;
    if (real_events != 2)
      $fatal(1, "real event count is %0d", real_events);
  end

  initial begin
    string_values = new[2]; string_values[0] = "one"; #2;
    string_values[1] = "ignored"; #2;
    string_values[0] = "one"; #2;
    string_values[0] = "two"; #7;
    if (string_events != 2)
      $fatal(1, "string event count is %0d", string_events);
    $display("PASSED");
    $finish;
  end
endmodule
