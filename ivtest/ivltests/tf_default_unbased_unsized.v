// Verify unbased unsized literals ('1, '0, 'x, 'z) and width/sign conversions
// in task, function, method, and constructor default arguments (Upstream #1840).
class Box;
  logic [31:0] init_v;
  function new(logic [31:0] v = '1);
    init_v = v;
  endfunction
  function logic [47:0] mask48(logic [47:0] m = '1);
    return m;
  endfunction
endclass

module tb;
  task automatic t_ones(input logic [31:0] v = '1, output logic [31:0] out);
    out = v;
  endtask

  task automatic t_xz(input logic [15:0] vx = 'x, input logic [15:0] vz = 'z,
                      output logic [15:0] ox, output logic [15:0] oz);
    ox = vx;
    oz = vz;
  endtask

  function automatic logic [31:0] f_ones(logic [31:0] v = '1);
    return v;
  endfunction

  function automatic logic [69:0] f_wide_ones(logic [69:0] v = '1);
    return v;
  endfunction

  localparam logic [31:0] CF_ONES = f_ones();

  logic [31:0] r32;
  logic [15:0] rx, rz;
  Box b;

  initial begin
    if (CF_ONES !== 32'hffff_ffff) begin
      $display("FAILED cfunc=%h", CF_ONES);
      $finish;
    end

    t_ones(, r32);
    if (r32 !== 32'hffff_ffff) begin
      $display("FAILED t_ones=%h", r32);
      $finish;
    end

    t_xz(, , rx, rz);
    if (rx !== 16'hxxxx || rz !== 16'hzzzz) begin
      $display("FAILED t_xz rx=%h rz=%h", rx, rz);
      $finish;
    end

    if (f_ones() !== 32'hffff_ffff || f_ones(32'h1234_5678) !== 32'h1234_5678) begin
      $display("FAILED f_ones=%h", f_ones());
      $finish;
    end

    if (f_wide_ones() !== {70{1'b1}}) begin
      $display("FAILED f_wide_ones=%h", f_wide_ones());
      $finish;
    end

    b = new();
    if (b.init_v !== 32'hffff_ffff || b.mask48() !== 48'hffff_ffff_ffff) begin
      $display("FAILED box init=%h mask=%h", b.init_v, b.mask48());
      $finish;
    end

    $display("PASSED");
  end
endmodule
