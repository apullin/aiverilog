module partial_output(
  input logic a,
  output logic [2:0] y
);
  assign y[2] = a & ~(|y[1:0]);
endmodule

module partial_bit_output(output bit [2:0] y);
  assign y[1] = 1'b1;
endmodule

module test;
  logic a;
  wire [2:0] y;
  logic [1:0] rhs = 2'b10;
  logic signed [4:0] partial;
  wire [4:0] partial_mirror = partial;
  logic [3:0] deposited;
  bit [2:0] two_state;
  logic [2:0] two_state_port;

  partial_output dut(.a(a), .y(y));
  partial_bit_output bit_dut(.y(two_state_port));
  assign partial[2:1] = rhs;
  assign deposited[2:1] = rhs;
  assign two_state[1] = 1'b1;

  initial begin
    a = 0;
    #1;
    if (y !== 3'b0xx) begin
      $display("FAILED: partially driven output initialized to %b", y);
      $finish;
    end
    if (partial !== 5'bxx10x || partial_mirror !== 5'bxx10x) begin
      $display("FAILED: partially driven variable initialized to %b/%b",
               partial, partial_mirror);
      $finish;
    end
    if (deposited !== 4'bx10x) begin
      $display("FAILED: deposit target initialized to %b", deposited);
      $finish;
    end
    if (two_state !== 3'b010 || two_state_port !== 3'b010) begin
      $display("FAILED: partially driven bit variables initialized to %b/%b",
               two_state, two_state_port);
      $finish;
    end

    $deposit(deposited, 4'b0001);
    #0;
    if (deposited !== 4'b0101) begin
      $display("FAILED: deposit produced %b", deposited);
      $finish;
    end

    a = 1;
    rhs = 2'b01;
    #1;
    if (y !== 3'bxxx || partial !== 5'bxx01x ||
        partial_mirror !== 5'bxx01x || deposited !== 4'b0011) begin
      $display("FAILED: update produced y=%b partial=%b/%b deposit=%b",
               y, partial, partial_mirror, deposited);
      $finish;
    end

    $display("PASSED");
  end
endmodule
