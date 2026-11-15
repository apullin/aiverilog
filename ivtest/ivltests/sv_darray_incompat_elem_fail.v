// Verify assigning dynamic arrays with incompatible element widths is rejected
// during elaboration rather than crashing vvp at runtime.
module top;
  typedef logic [128:0] wide_elem_t;
  typedef logic [7:0]   byte_array_t[];
  wide_elem_t result[];
  initial begin
    result = byte_array_t'(16'h12ab);
  end
endmodule
