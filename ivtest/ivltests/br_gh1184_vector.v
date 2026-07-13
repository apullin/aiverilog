`timescale 1ns/1ps

module modpath_dut(input wire [3:0] i, output wire [3:0] o);

assign o = i;

specify
  (i => o) = (4, 2);
endspecify

endmodule

module reference_dut(input wire [3:0] i, output wire [3:0] o);

assign #(4, 2) o[0] = i[0];
assign #(4, 2) o[1] = i[1];
assign #(4, 2) o[2] = i[2];
assign #(4, 2) o[3] = i[3];

endmodule

module test;

reg  [3:0] i;
wire [3:0] modpath_o;
wire [3:0] reference_o;
integer n;
integer errors;

modpath_dut modpath_dut(i, modpath_o);
reference_dut reference_dut(i, reference_o);

initial begin
  errors = 0;
  i = 4'bxxxx;

  fork
    begin: stimulus
      #0.25;
      for (n = 0; n < 48; n = n + 1) begin
        case (n % 12)
          0:  i = 4'b0000;
          1:  i = 4'b1111;
          2:  i = 4'b1010;
          3:  i = 4'b0101;
          4:  i = 4'b0011;
          5:  i = 4'b1100;
          6:  i = 4'bzz00;
          7:  i = 4'b00zz;
          8:  i = 4'bxx11;
          9:  i = 4'b11xx;
          10: i = 4'b0110;
          11: i = 4'b1001;
        endcase
        #1;
      end
      #10;
    end

    begin: checker
      #0.125;
      repeat (240) begin
        if (modpath_o !== reference_o) begin
          $display("mismatch at %0t: i=%b modpath=%b reference=%b",
                   $time, i, modpath_o, reference_o);
          errors = errors + 1;
        end
        #0.25;
      end
    end
  join

  if (errors)
    $display("FAILED");
  else
    $display("PASSED");
end

endmodule
