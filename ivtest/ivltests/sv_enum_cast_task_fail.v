// Failed task-form $cast to an enumeration reports a runtime error and leaves
// the destination variable unchanged.
module top;
  typedef enum logic [1:0] { E0 = 2'd0, E1 = 2'd1 } e_t;
  e_t e;
  initial begin
    e = E1;
    $cast(e, 3);
    if (e !== E1)
      $display("FAILED: failed task cast modified enum destination");
  end
endmodule
