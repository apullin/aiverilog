// Test for GitHub issue #1134
// Accessing member of packed struct in unpacked array should work
module test;

typedef struct packed {
    logic a;
    logic b;
} test_t;

test_t tests [0:1];
integer idx;

wire result_a;
wire result_b;

assign result_a = tests[0].a;
assign result_b = tests[1].b;

initial begin
    tests[0] = 2'b10;
    tests[1] = 2'b01;

    #1;

    if ((result_a !== 1'b1) || (result_b !== 1'b1)) begin
        $display("FAILED: result_a=%b result_b=%b", result_a, result_b);
        $finish;
    end
    idx = 0;
    if (tests[idx].a !== 1'b1) begin
        $display("FAILED: tests[idx=0].a = %b, expected 1", tests[idx].a);
        $finish;
    end
    idx = 1;
    if (tests[idx].a !== 1'b0) begin
        $display("FAILED: tests[idx=1].a = %b, expected 0", tests[idx].a);
        $finish;
    end
    idx = 2;
    if (tests[idx].a !== 1'bx) begin
        $display("FAILED: out-of-range struct member was not x");
        $finish;
    end
    $display("PASSED");
end

endmodule
