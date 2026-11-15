// Verify $setuphold delayed signals honor bit-selects and do not short
// mismatched parent vectors together.
module sub(input wire clk, input wire en, input wire d, output wire q);
  wire [-3:5] bl;
  wire [1:0] bl_x;
  reg notifier;
  assign bl[0] = d;
  assign bl_x[1] = 1'b0;
  assign q = bl_x[0];
  specify
    $setuphold(posedge clk &&& en, bl[0], 0, 0, notifier, , , , bl_x[0]);
  endspecify
endmodule

module top;
  reg clk = 0, en = 1, d = 0;
  wire q;
  sub u(.clk(clk), .en(en), .d(d), .q(q));
  initial begin
    #1;
    if (q !== 1'b0) begin $display("FAILED q0=%b", q); $finish; end
    d = 1'b1;
    #1;
    if (q !== 1'b1) begin $display("FAILED q1=%b", q); $finish; end
    $display("PASSED");
  end
endmodule
