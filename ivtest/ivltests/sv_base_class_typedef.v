// Test visibility of typedefs (and parameters) declared in a base class inside
// derived classes and out-of-body methods (Upstream #1869).
class W;
  int id;
  function new(int i = 99);
    id = i;
  endfunction
endclass

class Base;
  typedef W w_t;
  typedef logic [11:0] word12_t;
  localparam int BIAS = 5;
endclass

class Mid #(int WIDTH = 8) extends Base;
  typedef logic [WIDTH-1:0] lane_t;
  w_t m_w;
endclass

class Derived extends Mid #(16);
  w_t x;
  word12_t code;
  lane_t lane;

  function new();
    x = new(77);
    code = 12'h5a3;
    lane = 16'hbeef;
  endfunction

  function word12_t get_code(input word12_t extra);
    w_t tmp = x;
    return code + extra + word12_t'(BIAS) + word12_t'(tmp.id);
  endfunction

  extern function logic [15:0] ext_lane();
endclass

function logic [15:0] Derived::ext_lane();
  lane_t local_copy = lane;
  w_t ext_w = x;
  return (local_copy ^ 16'h000f) + 16'(ext_w.id - 77);
endfunction

module top;
  Derived d = new;
  W wx;
  initial begin
    wx = d.x;
    if (wx.id !== 77) begin
      $display("FAILED: wx.id=%0d", wx.id);
      $finish;
    end
    if (d.get_code(12'h001) !== (12'h5a3 + 12'h001 + 12'd5 + 12'd77)) begin
      $display("FAILED: get_code=%h", d.get_code(12'h001));
      $finish;
    end
    if (d.ext_lane() !== 16'hbee0) begin
      $display("FAILED: ext_lane=%h", d.ext_lane());
      $finish;
    end
    $display("PASSED");
  end
endmodule
