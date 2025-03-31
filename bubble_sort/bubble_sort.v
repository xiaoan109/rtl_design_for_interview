module bubble_sort #(
    parameter DW   = 8,
    parameter NUM  = 8,
    parameter MODE = 0   // 0 for max first, 1 for min first
) (
    input  wire [DW*NUM-1:0] data_i,
    output wire [DW*NUM-1:0] data_o
);

  reg [DW-1:0] tmp;
  reg [DW*NUM-1:0] data_r;
  integer i;
  integer j;

  generate
    if (MODE == 0) begin : gen_max_first
      always @(*) begin
        data_r = data_i;
        for (i = 0; i < NUM - 1; i = i + 1) begin
          for (j = 0; j < NUM - 1 - i; j = j + 1) begin
            if (data_r[(j+1)*DW+:DW] < data_r[j*DW+:DW]) begin
              tmp = data_r[j*DW+:DW];
              data_r[j*DW+:DW] = data_r[(j+1)*DW+:DW];
              data_r[(j+1)*DW+:DW] = tmp;
            end
          end
        end
      end
    end else if (MODE == 1) begin : gen_min_first
      always @(*) begin
        data_r = data_i;
        for (i = 0; i < NUM - 1; i = i + 1) begin
          for (j = i + 1; j < NUM; j = j + 1) begin
            if (data_r[j*DW+:DW] < data_r[i*DW+:DW]) begin
              tmp = data_r[i*DW+:DW];
              data_r[i*DW+:DW] = data_r[j*DW+:DW];
              data_r[j*DW+:DW] = tmp;
            end
          end
        end
      end
    end
  endgenerate

  assign data_o = data_r;

  // TODO: odd-even sort

endmodule
