// Verify out-of-bounds and undefined-index selects on 2-state packed vectors
// return '0 in constant, continuous-assign, and procedural contexts.
module top;
  bit [3:0] b = 4'b1111;
  logic [3:0] x_idx = 4'bx;
  wire [5:0] w_oob = b[4 -: 6];
  wire [1:0] w_x   = b[x_idx +: 2];
  logic [5:0] r_oob;
  logic [1:0] r_x;

  initial begin
    #1;
    r_oob = b[4 -: 6];
    r_x   = b[x_idx +: 2];
    if (w_oob !== 6'b011110 || r_oob !== 6'b011110 ||
        w_x !== 2'b00 || r_x !== 2'b00) begin
      $display("FAILED: w_oob=%b r_oob=%b w_x=%b r_x=%b", w_oob, r_oob, w_x, r_x);
      $finish;
    end
    $display("PASSED");
  end
endmodule
