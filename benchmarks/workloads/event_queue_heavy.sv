module event_cell #(
    parameter integer ID = 0
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] stimulus,
    output reg  [31:0] observed
);
  reg [31:0] state;
  reg [31:0] stage_a;
  reg [31:0] stage_b;

  always @(posedge clk) begin
    if (reset)
      state <= 32'h6d2b79f5 ^ ID;
    else
      state <= {state[30:0], state[31] ^ state[21] ^ state[1] ^ state[0]}
               + stimulus + ID;
  end

  always @(state or stimulus)
    stage_a <= {state[6:0], state[31:7]} ^ stimulus ^ (ID * 32'h9e3779b9);

  always @(stage_a)
    stage_b <= (stage_a + 32'h7f4a7c15) ^ (stage_a >> 11);

  always @(stage_b)
    observed <= {stage_b[15:0], stage_b[31:16]} ^ 32'ha5a5a5a5;
endmodule

module event_queue_bench;
  localparam integer CELLS = 384;
  localparam integer CYCLES = 60000;

  reg clk = 0;
  reg reset = 1;
  reg [31:0] stimulus = 32'h12345678;
  wire [31:0] observed [0:CELLS-1];
  reg [63:0] checksum;
  integer idx;

  genvar cell_idx;
  generate
    for (cell_idx = 0; cell_idx < CELLS; cell_idx = cell_idx + 1) begin: cells
      event_cell #(.ID(cell_idx)) cell_i(
          .clk(clk),
          .reset(reset),
          .stimulus(stimulus),
          .observed(observed[cell_idx])
      );
    end
  endgenerate

  always #1 clk = ~clk;

  always @(posedge clk) begin
    if (!reset)
      stimulus <= {stimulus[30:0], stimulus[31] ^ stimulus[21]
                                      ^ stimulus[1] ^ stimulus[0]};
  end

  initial begin
    repeat (8) @(posedge clk);
    @(negedge clk);
    reset = 0;
    repeat (CYCLES) @(posedge clk);
    @(negedge clk);

    checksum = 64'h243f6a8885a308d3;
    for (idx = 0; idx < CELLS; idx = idx + 1)
      checksum = {checksum[58:0], checksum[63:59]} ^ observed[idx] ^ idx;

    $display("event_queue cells=%0d cycles=%0d checksum=%016x",
             CELLS, CYCLES, checksum);
    $finish(0);
  end
endmodule
