// Test for GitHub issue #1202
// A SystemVerilog input port with a default value is meant to take
// that default when unconnected. For a top-level module instance
// nothing supplies the connection, so the default must be driven by
// the front end. iverilog previously left the port at `z'.

module test (input a = 0, input b = 1'b1, output x);
  reg failed = 1'b0;
  assign x = a;

  initial begin
    #1;
    if (a !== 1'b0) begin
      $display("FAILED: a=%b, expected 0", a);
      failed = 1'b1;
    end
    if (b !== 1'b1) begin
      $display("FAILED: b=%b, expected 1", b);
      failed = 1'b1;
    end
    if (x !== 1'b0) begin
      $display("FAILED: x=%b, expected 0", x);
      failed = 1'b1;
    end
    if (!failed) $display("PASSED");
    $finish();
  end
endmodule

module typed_default #(parameter logic P = 1'b1) (input logic a = P);
  initial begin
    #1;
    if (a !== P) begin
      $display("FAILED: typed default a=%b, expected %b", a, P);
      $finish;
    end
  end
endmodule

module variable_default (input var logic a = 1'b1);
  initial begin
    #1;
    if (a !== 1'b1) begin
      $display("FAILED: variable default a=%b, expected 1", a);
      $finish;
    end
  end
endmodule
