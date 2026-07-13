package t_pkg;
  typedef bit unsigned [31:0] addr_t;

  function void get_addrs(addr_t addr_q[$]);
  endfunction
endpackage

module test;
  import t_pkg::*;
  bit [3:0] addr_q[$];

  initial get_addrs(addr_q);
endmodule
