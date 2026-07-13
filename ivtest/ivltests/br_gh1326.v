module plain_initial_first(output bit caught);
  bit signal = 1;
  initial signal = 0;
  always @(negedge signal) caught <= 1;
endmodule

module plain_always_first(output bit caught);
  bit signal = 1;
  always @(negedge signal) caught <= 1;
  initial signal = 0;
endmodule

module ff_initial_first(output bit caught);
  bit signal = 1;
  initial signal = 0;
  always_ff @(negedge signal) caught <= 1;
endmodule

module mixed_edges(output bit caught);
  bit rise_signal = 0;
  bit fall_signal = 1;
  initial fall_signal = 0;
  always @(posedge rise_signal or negedge fall_signal) caught <= 1;
endmodule

module declaration_only(output bit caught);
  bit signal = 0;
  always @(negedge signal) caught <= 1;
endmodule

module test;
  wire plain_first;
  wire plain_last;
  wire ff_first;
  wire mixed;
  wire declaration_edge;

  plain_initial_first u_plain_first(plain_first);
  plain_always_first u_plain_last(plain_last);
  ff_initial_first u_ff_first(ff_first);
  mixed_edges u_mixed(mixed);
  declaration_only u_declaration_only(declaration_edge);

  initial begin
    #1;
    if ({plain_first, plain_last, ff_first, mixed, declaration_edge} === 5'b11110)
      $display("PASSED");
    else
      $display("FAILED: %b%b%b%b%b", plain_first, plain_last, ff_first,
               mixed, declaration_edge);
  end
endmodule
