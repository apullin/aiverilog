// Verify dynamic-array constructor initialization from elementary literals,
// elementary variables (including side-effecting function calls), and wide
// packed vectors whose element offsets exceed 64 bits.
module darray_new_elem_init;
  int d[];
  int v = 42;
  int calls = 0;
  bit [95:0] p = {32'd100, 32'd200, 32'd300};

  function int next_val();
    calls = calls + 1;
    return 77;
  endfunction

  initial begin
    d = new[4](42);
    if (d.size() != 4 || d[0] !== 42 || d[1] !== 42 || d[2] !== 42 || d[3] !== 42) begin
      $display("FAILED literal: %0d %0d %0d %0d", d[0], d[1], d[2], d[3]);
      $finish;
    end

    d = new[3](v);
    if (d.size() != 3 || d[0] !== 42 || d[1] !== 42 || d[2] !== 42) begin
      $display("FAILED var: %0d %0d %0d", d[0], d[1], d[2]);
      $finish;
    end

    d = new[3](next_val());
    if (calls != 1 || d[0] !== 77 || d[1] !== 77 || d[2] !== 77) begin
      $display("FAILED func: calls=%0d %0d %0d %0d", calls, d[0], d[1], d[2]);
      $finish;
    end

    d = new[3](p);
    if (d.size() != 3 || d[0] !== 100 || d[1] !== 200 || d[2] !== 300) begin
      $display("FAILED packed: %0d %0d %0d", d[0], d[1], d[2]);
      $finish;
    end

    $display("PASSED");
  end
endmodule
