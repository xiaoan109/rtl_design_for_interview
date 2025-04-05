module onehot_to_bin #(
    parameter ONEHOT_WIDTH = 8,
    parameter BIN_WIDTH = ONEHOT_WIDTH == 1 ? 1 : $clog2(ONEHOT_WIDTH)
) (
    input wire [ONEHOT_WIDTH-1:0] onehot_i,
    output wire [BIN_WIDTH-1:0] bin_o
);

  // for-loop method is ignored



  // eg. 8bit onehot, 3bit bin
  // BIN       ONEHOT
  // 000      00000001
  // 001      00000010
  // 010      00000100
  // 011      00001000
  // 100      00010000
  // 101      00100000
  // 110      01000000
  // 111      10000000

  genvar i;
  genvar j;
  generate
    for (i = 0; i < BIN_WIDTH; i = i + 1) begin : gen_il
      wire [ONEHOT_WIDTH-1:0] tmp_mask;
      for (j = 0; j < ONEHOT_WIDTH; j = j + 1) begin : gen_jl
        wire [BIN_WIDTH-1:0] tmp_j;
        assign tmp_j = j;
        assign tmp_mask[j] = tmp_j[i];
      end
      assign bin_o[i] = |(tmp_mask & onehot_i);
    end
  endgenerate
endmodule
