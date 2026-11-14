// Verify procedural and continuous assignments to struct members inside
// unpacked arrays of packed arrays of packed structs.
typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} pair_t;

module uarray_packed_struct_lval;
  pair_t [1:0] arr [0:2];
  wire pair_t [1:0] warr [0:1];
  int ui, pi;

  assign warr[0][0].hi = 4'h9;
  assign warr[0][0].lo = 4'h6;
  assign warr[0][1].hi = 4'hc;
  assign warr[0][1].lo = 4'h3;
  assign warr[1][0]    = 8'h12;
  assign warr[1][1]    = 8'h34;

  initial begin
    arr[0] = 16'h0000;
    arr[1] = 16'h0000;
    arr[2] = 16'h0000;

    // Constant unpacked and packed indices
    arr[1][0].lo = 4'ha;
    arr[1][0].hi = 4'h1;
    arr[1][1].lo = 4'h2;
    arr[1][1].hi = 4'h5;

    // Dynamic unpacked and packed indices
    ui = 2;
    pi = 1;
    arr[ui][pi].hi = 4'he;
    arr[ui][0].lo  = 4'h7;

    #1;
    if (arr[1] !== 16'h521a) begin
      $display("FAILED: arr[1]=%h expected 521a", arr[1]);
      $finish;
    end
    if (arr[2] !== 16'he007) begin
      $display("FAILED: arr[2]=%h expected e007", arr[2]);
      $finish;
    end
    if (warr[0] !== 16'hc396 || warr[1] !== 16'h3412) begin
      $display("FAILED: warr[0]=%h warr[1]=%h", warr[0], warr[1]);
      $finish;
    end
    $display("PASSED");
  end
endmodule
