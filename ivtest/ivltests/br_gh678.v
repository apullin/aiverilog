module test;

reg x, y;
reg [1:0] value;
wire sum = value[0] + value[1];
integer concat_events = 0;
integer signal_events = 0;
integer direct_events = 0;
integer wire_events = 0;
integer posedge_events = 0;

always @(x + y)
  concat_events = concat_events + 1;

always @(x or y)
  signal_events = signal_events + 1;

always @(value[0] + value[1])
  direct_events = direct_events + 1;

always @(sum)
  wire_events = wire_events + 1;

always @(posedge sum)
  posedge_events = posedge_events + 1;

initial begin
  #1 {x, y} = 2'b00; value = 2'b00;
  #1 {x, y} = 2'b01; value = 2'b01;
  #1 {x, y} = 2'b10; value = 2'b10;
  #1 {x, y} = 2'b11; value = 2'b11;
  #1 {x, y} = 2'b00; value = 2'b00;
  #1 {x, y} = 2'b10; value = 2'b10;
  #1;

  if (concat_events != 4 || signal_events != 6 ||
      direct_events != 4 || wire_events != 4 || posedge_events != 2)
    $display("FAILED: concat=%0d signals=%0d direct=%0d wire=%0d posedge=%0d",
             concat_events, signal_events, direct_events, wire_events,
             posedge_events);
  else
    $display("PASSED");
end

endmodule
