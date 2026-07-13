module test;
  task empty_task(input integer value);
  endtask

  function void empty_function(input integer value);
  endfunction

  initial begin
    empty_task(42);
    empty_function(17);

    if (empty_task.value !== 42)
      $display("FAILED: empty task input was not copied");
    else if (empty_function.value !== 17)
      $display("FAILED: empty function input was not copied");
    else
      $display("PASSED");
  end
endmodule
