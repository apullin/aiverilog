module test;
  typedef struct packed {
    logic [2:0] payload;
    logic flag;
  } inner_t;

  typedef struct packed {
    logic tag;
    inner_t inner;
  } outer_t;

  outer_t [1:0] descending;
  outer_t [0:1] ascending;
  outer_t [-1:-2] offset;
  integer i;
  reg failed = 0;

  initial begin
    descending = '0;
    foreach (descending[i]) begin
      descending[i].tag = i[0];
      descending[i].inner.payload = i + 3;
      descending[i].inner.flag = ~i[0];
    end
    if (descending[0].tag !== 0 ||
        descending[0].inner.payload !== 3 ||
        descending[0].inner.flag !== 1 ||
        descending[1].tag !== 1 ||
        descending[1].inner.payload !== 4 ||
        descending[1].inner.flag !== 0) begin
      $display("FAILED: descending: %h", descending);
      failed = 1;
    end

    ascending = '0;
    for (i = 0; i <= 1; i = i + 1) begin
      ascending[i].tag = ~i[0];
      ascending[i].inner.payload = i + 5;
      ascending[i].inner.flag = i[0];
    end
    if (ascending[0].tag !== 1 ||
        ascending[0].inner.payload !== 5 ||
        ascending[0].inner.flag !== 0 ||
        ascending[1].tag !== 0 ||
        ascending[1].inner.payload !== 6 ||
        ascending[1].inner.flag !== 1) begin
      $display("FAILED: ascending: %h", ascending);
      failed = 1;
    end

    offset = '0;
    for (i = -1; i >= -2; i = i - 1) begin
      offset[i].tag = i == -2;
      offset[i].inner.payload = -i;
      offset[i].inner.flag = i == -1;
    end
    if (offset[-1].tag !== 0 ||
        offset[-1].inner.payload !== 1 ||
        offset[-1].inner.flag !== 1 ||
        offset[-2].tag !== 1 ||
        offset[-2].inner.payload !== 2 ||
        offset[-2].inner.flag !== 0) begin
      $display("FAILED: offset: %h", offset);
      failed = 1;
    end

    if (!failed)
      $display("PASSED");
  end
endmodule
