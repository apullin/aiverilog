module a(input wire i1 [1:2]);
  assign i1 = '{'b1, 'b0};
endmodule

module b;
  wire w [1:2];
  a a_inst(.i1(w));
endmodule
