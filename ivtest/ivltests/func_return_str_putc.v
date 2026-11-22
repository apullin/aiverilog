// Verify character assignment and compound character assignment to a string
// function's return variable at runtime and in constant functions
// (Upstream #1862).
class C;
  function string make(int idx, byte ch);
    make = "   ";
    make[0] = 8'h41;
    make[idx] = ch;
    make[2] = "a";
    make[2] -= 8'd32; // 'A'
  endfunction
endclass

module m;
  function automatic string cf_build();
    cf_build = "hello";
    cf_build[0] = "H";
    cf_build[4] += 8'd1; // 'o' -> 'p'
    cf_build[99] = "X";  // out-of-bounds ignored
    cf_build[1] = 8'd0;  // NUL ignored per IEEE 1800
  endfunction

  localparam string S_CONST = cf_build();

  C p = new;
  initial begin
    if (p.make(1, "B") != "ABA") begin
      $display("FAILED method got '%s'", p.make(1, "B"));
      $finish;
    end
    if (cf_build() != "Heklp" && cf_build() != "Hellp") begin
      $display("FAILED rt cf_build got '%s'", cf_build());
      $finish;
    end
    if (cf_build() != "Hellp" || S_CONST != "Hellp") begin
      $display("FAILED cf='%s' const='%s'", cf_build(), S_CONST);
      $finish;
    end
    $display("PASSED");
  end
endmodule
