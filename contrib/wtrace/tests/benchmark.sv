`timescale 1ns/1ps

module benchmark_dut(input wire clk);
  reg [31:0] cycle;

  initial cycle = 0;
  always @(posedge clk) cycle <= cycle + 1'b1;

  genvar lane;
  generate
    for (lane = 0; lane < 256; lane = lane + 1) begin : lanes
      reg [31:0] value;
      wire [31:0] mixed = value ^ (32'h9e3779b9 * lane);

      initial value = 32'h10203040 + lane;
      always @(posedge clk) begin
        if (cycle[3:0] == (lane & 15))
          value <= {value[30:0], value[31] ^ value[21] ^ value[1] ^ value[0]};
      end
    end
  endgenerate
endmodule

module tb;
  parameter CYCLES = 10000;
  reg clk;
  benchmark_dut dut(.clk(clk));

  initial begin
    clk = 0;
`ifdef WTRACE
    $wtracefile("benchmark.wtr");
    $wtracevars(clk, tb);
`elsif VCD
    $dumpfile("benchmark.vcd");
    $dumpvars(0, tb);
`elsif FST
    $dumpfile("benchmark.fst");
    $dumpvars(0, tb);
`endif
    repeat (CYCLES * 2) #1 clk = ~clk;
    $finish;
  end
endmodule
