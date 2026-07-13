module main;
   logic [1:0] value;

   initial begin
      value = 2'b00;
      unique case (value)
        2'b00: $display("unique first");
        2'b00: $display("FAILED: unique second");
        default: $display("FAILED: unique default");
      endcase

      value = 2'b11;
      unique0 case (value)
        2'b00: $display("FAILED: unique0 no-match");
      endcase

      value = 2'b00;
      unique0 casex (value)
        2'b0x: $display("casex first");
        2'bx0: $display("FAILED: casex second");
      endcase

      unique0 casez (value)
        2'b0?: $display("casez first");
        2'b?0: $display("FAILED: casez second");
      endcase

      priority case (value)
        2'b00: $display("priority first");
        2'b00: $display("FAILED: priority second");
      endcase

      value = 2'b11;
      unique case (value)
        2'b00: $display("FAILED: unique no-match");
      endcase

      value = 2'b00;
      unique case (value)
        2'b00, 2'b00: $display("comma-separated item");
        default: $display("FAILED: comma-separated default");
      endcase

      $display("PASSED");
   end
endmodule
