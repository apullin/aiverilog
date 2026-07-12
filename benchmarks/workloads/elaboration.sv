module elaboration_leaf #(
    parameter integer ID = 0,
    parameter integer WIDTH = 32
) (
    input  wire [WIDTH-1:0] source,
    output wire [WIDTH-1:0] result
);
  localparam [WIDTH-1:0] MASK_A = ID * 32'h9e3779b9;
  localparam [WIDTH-1:0] MASK_B = (ID + 17) * 32'h7f4a7c15;
  wire [WIDTH-1:0] stage [0:7];

  assign stage[0] = source ^ MASK_A;

  genvar stage_idx;
  generate
    for (stage_idx = 1; stage_idx < 8; stage_idx = stage_idx + 1) begin: stages
      if ((stage_idx & 1) == 0)
        assign stage[stage_idx] = (stage[stage_idx-1] << stage_idx)
                                  ^ (MASK_B >> stage_idx);
      else
        assign stage[stage_idx] = (stage[stage_idx-1] + MASK_B)
                                  ^ (stage[stage_idx-1] >> stage_idx);
    end
  endgenerate

  assign result = stage[7] ^ MASK_A ^ MASK_B;
endmodule

module elaboration_bench;
  localparam integer INSTANCES = 1500;

  reg [31:0] source = 32'h6a09e667;
  wire [31:0] result [0:INSTANCES-1];
  reg [63:0] checksum;
  integer idx;

  genvar leaf_idx;
  generate
    for (leaf_idx = 0; leaf_idx < INSTANCES; leaf_idx = leaf_idx + 1) begin: leaves
      elaboration_leaf #(.ID(leaf_idx)) leaf_i(
          .source(source),
          .result(result[leaf_idx])
      );
    end
  endgenerate

  initial begin
    #1;
    checksum = 64'hbb67ae8584caa73b;
    for (idx = 0; idx < INSTANCES; idx = idx + 1)
      checksum = {checksum[56:0], checksum[63:57]} ^ result[idx] ^ idx;

    $display("elaboration instances=%0d checksum=%016x", INSTANCES, checksum);
    $finish(0);
  end
endmodule
