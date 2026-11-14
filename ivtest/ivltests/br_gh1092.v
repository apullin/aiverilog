// Regression test for upstream #1092:
// IEEE 1800-2017 11.4.13 set-membership 'inside' operator.
module top;
  // Constant / localparam evaluation
  localparam bit LP_HIT   = (8'd15 inside {8'd3, [8'd10:8'd20], 8'd99});
  localparam bit LP_MISS  = (8'd25 inside {8'd3, [8'd10:8'd20], 8'd99});
  localparam bit LP_WILD  = (4'b1011 inside {4'b10??});
  localparam bit LP_EMPTY = (4'bx   inside {[4'd9:4'd3]}); // lo > hi -> 1'b0

  logic [7:0] sig_x;
  wire        w_inside = sig_x inside {8'h10, [8'h20:8'h2f], 8'b1100_????};

  int    uarr[0:2];
  int    q[$];
  int    da[];
  string sq[$];

  initial begin
    logic r;
    int   sv;
    real  rv;
    string s;

    if (LP_HIT !== 1'b1 || LP_MISS !== 1'b0 ||
        LP_WILD !== 1'b1 || LP_EMPTY !== 1'b0) begin
      $display("FAILED localparams: %b %b %b %b",
               LP_HIT, LP_MISS, LP_WILD, LP_EMPTY);
      $finish;
    end

    // Continuous assign + wildcard RHS
    sig_x = 8'h25; #1;
    if (w_inside !== 1'b1) begin $display("FAILED cont 1"); $finish; end
    sig_x = 8'hc9; #1;
    if (w_inside !== 1'b1) begin $display("FAILED cont wild"); $finish; end
    sig_x = 8'h55; #1;
    if (w_inside !== 1'b0) begin $display("FAILED cont miss"); $finish; end

    // Asymmetric 4-state semantics: X in LHS yields 1'bx unless matched!
    sig_x = 8'b0100_000x;
    r = sig_x inside {8'h40, 8'h99};
    if (r !== 1'bx) begin
      $display("FAILED 4-state unknown: got %b", r);
      $finish;
    end
    r = sig_x inside {8'h40, 8'b0100_000?};
    if (r !== 1'b1) begin
      $display("FAILED 4-state match overrides x: got %b", r);
      $finish;
    end

    // Precedence with &&, +, !, and [$:hi] / [lo:$] open bounds
    sv = -4;
    if (!(sv + 1 inside {[-10:-3]} && !(sv inside {[0:$]}))) begin
      $display("FAILED signed range / precedence / open $");
      $finish;
    end
    if (!(sv inside {[$:-1]})) begin
      $display("FAILED [$:hi] open bound");
      $finish;
    end

    // Unpacked array, queue, and dynamic array items
    uarr[0] = 11; uarr[1] = 22; uarr[2] = 33;
    q.push_back(100); q.push_back(200);
    da = new[2]; da[0] = -7; da[1] = 42;
    if (!(22 inside {uarr}) || (23 inside {uarr})) begin
      $display("FAILED fixed unpacked array inside");
      $finish;
    end
    if (!(200 inside {uarr, q, da}) || !(-7 inside {q, da}) || (999 inside {q, da})) begin
      $display("FAILED queue/darray inside");
      $finish;
    end

    // Real and string operands
    rv = 3.25;
    if (!(rv inside {1.0, [3.0:3.5]}) || (rv inside {[4.0:5.0]})) begin
      $display("FAILED real inside");
      $finish;
    end
    s = "beta";
    sq.push_back("alpha"); sq.push_back("beta");
    if (!(s inside {"gamma", sq}) || ("delta" inside {sq})) begin
      $display("FAILED string inside");
      $finish;
    end

    $display("PASSED");
  end
endmodule
