module test;
  localparam logic [3:0] X = 4'b00x1;
  localparam logic [3:0] Z = 4'b00z1;

  logic [X:0] packed_msb;
  logic [0:Z] packed_lsb;
  logic [X] packed_size;
  logic unpacked_msb [X:0];
  logic unpacked_lsb [0:Z];
  typedef logic [Z:0] packed_t;
  typedef logic unpacked_t [0:X];
  packed_t typed_value;
  unpacked_t unpacked_value;
endmodule
