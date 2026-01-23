// Test for GitHub issue #1134
// Accessing member of packed struct in unpacked array should work
typedef struct packed {
    logic a, b;
} test_t;

module test;
    // tests[0] = {a:0, b:1}, tests[1] = {a:1, b:0}
    test_t tests [0:1] = '{'{'b0, 'b1}, '{'b1, 'b0}};
    wire w0, w1;
    integer idx;

    assign w0 = tests[0].a;  // Should be 0
    assign w1 = tests[1].a;  // Should be 1

    initial begin
        #1;
        if (w0 !== 1'b0) begin
            $display("FAILED: tests[0].a = %b, expected 0", w0);
            $finish;
        end
        if (w1 !== 1'b1) begin
            $display("FAILED: tests[1].a = %b, expected 1", w1);
            $finish;
        end
        idx = 0;
        if (tests[idx].a !== 1'b0) begin
            $display("FAILED: tests[idx=0].a = %b, expected 0", tests[idx].a);
            $finish;
        end
        idx = 1;
        if (tests[idx].a !== 1'b1) begin
            $display("FAILED: tests[idx=1].a = %b, expected 1", tests[idx].a);
            $finish;
        end
        if (tests[2].a !== 1'bx) begin
            $display("FAILED: out-of-range struct member was not x");
            $finish;
        end
        $display("PASSED");
    end
endmodule
