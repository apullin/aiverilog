`timescale 1ns/1ps

module dut(input wire clk);
  reg [7:0] count;
  reg [7:0] shadow;
  reg [3:0] four_state;
  reg [0:3] ascending;
  reg [7:0] memory [0:3];
  reg glitch;
  wire parity = ^count;
  integer idx;

  initial begin
    count = 0;
    shadow = 8'hff;
    four_state = 4'b10xz;
    ascending = 4'b01xz;
    glitch = 0;
    for (idx = 0; idx < 4; idx = idx + 1)
      memory[idx] = idx;
    #2 glitch = 1;
    #1 glitch = 0;
  end

  always @(posedge clk) begin
    memory[count[1:0]] <= count;
    count <= count + 1'b1;
  end

  always @(negedge clk) begin
    if ($time != 0) begin
      shadow <= count ^ 8'h5a;
      four_state <= {four_state[2:0], four_state[3]};
    end
  end
endmodule

module tb;
  reg clk;
  dut dut(.clk(clk));

  initial begin
    clk = 0;
    $wtracefile("basic.wtr");
    $wtracevars(clk, dut);
    repeat (8) #5 clk = ~clk;
    #1 $finish;
  end
endmodule
