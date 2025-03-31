`timescale 1ns / 10ps

module tb_onehot_det ();

  reg [7:0] data_i;
  wire is_onehot_o_0;
  wire is_onehot_o_1;
  wire is_onehot_o_2;
  reg [7:0] rand_data_r;

  onehot_det #(
      .DW  (8),
      .MODE(0)
  ) dut (
      .*,
      .is_onehot_o(is_onehot_o_0)
  );

  onehot_det #(
      .DW  (8),
      .MODE(1)
  ) dut1 (
      .*,
      .is_onehot_o(is_onehot_o_1)
  );

  onehot_det #(
      .DW  (8),
      .MODE(1)
  ) dut2 (
      .*,
      .is_onehot_o(is_onehot_o_2)
  );


  initial begin
    repeat (20) begin
      #10 data_i <= $urandom();
    end
    repeat (20) begin
      #10 std::randomize(rand_data_r) with {$onehot(rand_data_r) == 1;};
      data_i <= rand_data_r;
    end
    #10;
    $finish();
  end

  always #10 begin
    $display("[MODE0]@%0t, data_i: %08b, is_onehot: %0d", $time, data_i, is_onehot_o_0);
    $display("[MODE1]@%0t, data_i: %08b, is_onehot: %0d", $time, data_i, is_onehot_o_1);
    $display("[MODE2]@%0t, data_i: %08b, is_onehot: %0d", $time, data_i, is_onehot_o_2);
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_onehot_det);
  end
endmodule
