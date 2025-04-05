`default_nettype none
module zero_pos_find #(
    parameter LSB_FIRST = 0,
    parameter MODE = 3,  // 0 for 2-split, 1 for for-loop, 2 for onehot adder, 3 for simple or
    parameter DW = 8,
    parameter DW_SIZE = DW == 1 ? 1 : $clog2(DW)
) (
    input wire [DW-1:0] data_i,
    output wire [DW-1:0] pos_onehot_o,  // one-hot
    output wire [$clog2(DW)-1:0] pos_o
);

  // 2-spilt
  // TODO: how to parametize


  // for-loop
  generate
    if (MODE == 1) begin : gen_for_loop
      integer i;
      reg [DW_SIZE-1:0] first1_loc_r;
      if (LSB_FIRST == 0) begin : gen_msb
        always @(*) begin
          first1_loc_r = 0;
          for (i = 0; i < DW; i = i + 1) begin
            if (data_i[i]) begin
              first1_loc_r = i;
            end
          end
        end
      end else begin : gen_lsb
        always @(*) begin
          first1_loc_r = 0;
          for (i = DW - 1; i >= 0; i = i - 1) begin
            if (data_i[i]) begin
              first1_loc_r = i;
            end
          end
        end
      end
      assign pos_o = first1_loc_r;
      assign pos_onehot_o = 1 << pos_o;
    end else if (MODE == 2) begin : gen_one_hot_adder

      integer i;
      reg [DW-1:0] data_invert_r;
      wire [DW-1:0] pos_onehot_r;
      reg [DW-1:0] pos_onehot_invert_r;

      wire is_all0_w;
      wire [DW-1:0] data_m1_w;  // minus 1
      wire [DW-1:0] data_m1_inv_w;  // bit invert

      reg [DW_SIZE-1:0] binary_r;

      always @(*) begin
        for (i = 0; i < DW; i = i + 1) begin
          data_invert_r[i] = LSB_FIRST ? data_i[i] : data_i[DW-1-i];
        end
      end

      assign is_all0_w = ~|data_invert_r;
      assign data_m1_w = is_all0_w ? data_invert_r : data_invert_r - 1'b1;
      assign data_m1_inv_w = ~data_m1_w;
      assign pos_onehot_r = data_invert_r & data_m1_inv_w;
      always @(*) begin
        for (i = 0; i < DW; i = i + 1) begin
          pos_onehot_invert_r[i] = LSB_FIRST ? pos_onehot_r[i] : pos_onehot_r[DW-1-i];
        end
      end
      assign pos_onehot_o = pos_onehot_invert_r;
      // convert onehot to binary, not a good idea
      always @(*) begin
        binary_r = 0;
        for (i = 0; i < DW; i = i + 1) begin
          if (pos_onehot_o[i]) begin
            binary_r = i;
          end
        end
      end

      assign pos_o = binary_r;

    end else if (MODE == 3) begin : gen_simple_or
      wire [DW-1:0] tmp_w;

      reg [DW_SIZE-1:0] binary_r;
      integer i;
      if (LSB_FIRST == 0) begin : gen_msb
        assign tmp_w = {1'b0, tmp_w[DW-1:1] | data_i[DW-1:1]};
      end else begin : gen_lsb
        assign tmp_w = {tmp_w[DW-2:0] | data_i[DW-2:0], 1'b0};
      end

      assign pos_onehot_o = ~tmp_w & data_i;
      // convert onehot to binary, not a good idea
      always @(*) begin
        binary_r = 0;
        for (i = 0; i < DW; i = i + 1) begin
          if (pos_onehot_o[i]) begin
            binary_r = i;
          end
        end
      end

      assign pos_o = binary_r;
    end
  endgenerate





endmodule
