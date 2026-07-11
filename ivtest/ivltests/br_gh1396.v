typedef enum logic [7:0] { ENUM_ZERO = 8'h00 } byte_enum_t;

module main;
  logic [7:0] value;
  byte_enum_t enum_value;

  function automatic logic use_enum(input byte_enum_t argument);
    return argument == ENUM_ZERO;
  endfunction

  initial begin
    enum_value = value;
    $display("%0d", use_enum(value));
  end
endmodule
