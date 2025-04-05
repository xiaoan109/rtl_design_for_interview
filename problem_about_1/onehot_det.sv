module onehot_det #(
    parameter DW   = 8,
    parameter MODE = 0   // 0 for sum, 1 for minus1 method, 2 for parity xor method
) (
    input wire [DW-1:0] data_i,
    output wire is_onehot_o
);

  generate
    if (MODE == 0) begin : gen_sum
      reg [$clog2(DW):0] sum_r;
      integer i;

      always @(*) begin
        sum_r = 0;
        for (i = 0; i < DW; i = i + 1) begin
          sum_r = sum_r + data_i[i];
        end
      end

      assign is_onehot_o = (sum_r == 1);
    end else if (MODE == 1) begin : gen_m1
      wire [DW-1:0] data_m1_w;
      wire [DW-1:0] data_and_w;
      assign data_m1_w   = data_i - 1'b1;
      assign data_and_w  = data_i & data_m1_w;
      assign is_onehot_o = (data_i != 0) && (data_and_w == 0);
    end else if (MODE == 2) begin : gen_parity_xor
      reg [DW-1:0] parity;
      integer i;
      always @(*) begin
        parity[0] = data_i[0];
        for (i = 0; i < DW; i = i + 1) begin
          parity[i] = parity[i-1] ^ data_i[i];
        end
      end
      assign is_onehot_o = parity[i-1] && (&(parity | ~data_i));
    end
  endgenerate


endmodule
