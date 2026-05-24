// Test for GitHub issue #1103
// fork-join_none inside an automatic task hit a vvp runtime
// assertion in of_JOIN_DETACH. The compiler must report a proper
// "sorry: not supported" diagnostic at code-generation time instead.

module top;
    task automatic test_task;
        fork
            $display("inside fork");
            $display("inside fork2");
        join_none;
        $display("Test task completes");
    endtask
    initial test_task();
endmodule
