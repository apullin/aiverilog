module test;
  logic [1:0] array_value[2];

  task set_value(output logic [1:0] value);
    value = 2'b01;
  endtask

  initial
    set_value(array_value);
endmodule
