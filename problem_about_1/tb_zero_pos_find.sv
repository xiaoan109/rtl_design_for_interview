`timescale 1ns / 10ps

module tb_zero_pos_find ();
  reg  [7:0] data_i;
  wire [7:0] pos_onehot_o_0;
  wire [2:0] pos_o_0;
  wire [7:0] pos_onehot_o_1;
  wire [2:0] pos_o_1;
  wire [7:0] pos_onehot_o_2;
  wire [2:0] pos_o_2;
  wire [7:0] pos_onehot_o_3;
  wire [2:0] pos_o_3;
  wire [7:0] pos_onehot_o_4;
  wire [2:0] pos_o_4;
  wire [7:0] pos_onehot_o_5;
  wire [2:0] pos_o_5;

  zero_pos_find #(
      .LSB_FIRST(0),
      .MODE(1),
      .DW(8)
  ) dut0 (
      .*,
      .pos_onehot_o(pos_onehot_o_0),
      .pos_o(pos_o_0)
  );

  zero_pos_find #(
      .LSB_FIRST(1),
      .MODE(1),
      .DW(8)
  ) dut1 (
      .*,
      .pos_onehot_o(pos_onehot_o_1),
      .pos_o(pos_o_1)
  );

  zero_pos_find #(
      .LSB_FIRST(0),
      .MODE(2),
      .DW(8)
  ) dut2 (
      .*,
      .pos_onehot_o(pos_onehot_o_2),
      .pos_o(pos_o_2)
  );

  zero_pos_find #(
      .LSB_FIRST(1),
      .MODE(2),
      .DW(8)
  ) dut3 (
      .*,
      .pos_onehot_o(pos_onehot_o_3),
      .pos_o(pos_o_3)
  );

  zero_pos_find #(
      .LSB_FIRST(0),
      .MODE(3),
      .DW(8)
  ) dut4 (
      .*,
      .pos_onehot_o(pos_onehot_o_4),
      .pos_o(pos_o_4)
  );

  zero_pos_find #(
      .LSB_FIRST(1),
      .MODE(3),
      .DW(8)
  ) dut5 (
      .*,
      .pos_onehot_o(pos_onehot_o_5),
      .pos_o(pos_o_5)
  );

  initial begin
    repeat (20) begin
      #10 data_i <= $urandom();
    end
    #10;
    $finish();
  end

  always #10 begin
    $display("[MODE1]@%0t, data_t: %08b, MSB pos_onehot_o: %08b, MSB pos_o: %d", $time, data_i,
             pos_onehot_o_0, pos_o_0);
    $display("[MODE1]@%0t, data_t: %08b, LSB pos_onehot_o: %08b, LSB pos_o: %d", $time, data_i,
             pos_onehot_o_1, pos_o_1);
    $display("[MODE2]@%0t, data_t: %08b, MSB pos_onehot_o: %08b, MSB pos_o: %d", $time, data_i,
             pos_onehot_o_2, pos_o_2);
    $display("[MODE2]@%0t, data_t: %08b, LSB pos_onehot_o: %08b, LSB pos_o: %d", $time, data_i,
             pos_onehot_o_3, pos_o_3);
    $display("[MODE3]@%0t, data_t: %08b, MSB pos_onehot_o: %08b, MSB pos_o: %d", $time, data_i,
             pos_onehot_o_4, pos_o_4);
    $display("[MODE3]@%0t, data_t: %08b, LSB pos_onehot_o: %08b, LSB pos_o: %d", $time, data_i,
             pos_onehot_o_5, pos_o_5);
  end



endmodule
