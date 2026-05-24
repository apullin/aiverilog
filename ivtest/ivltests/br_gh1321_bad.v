// A block cannot have both a prefix statement label and a suffix block name.
module test;
  initial begin
    first_name: begin : second_name
      $display("must not compile");
    end
  end
endmodule
