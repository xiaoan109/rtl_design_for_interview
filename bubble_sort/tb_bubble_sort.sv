`timescale 1ns / 10ps

module tb_bubble_sort ();
  reg [8*8-1:0] data_i;
  wire [8*8-1:0] data_o_0;
  wire [8*8-1:0] data_o_1;

  bit [7:0] data_q[];
  reg [8*8-1:0] data_r;

  bubble_sort #(
      .DW  (8),
      .NUM (8),
      .MODE(0)
  ) dut (
      .*,
      .data_o(data_o_0)
  );

  bubble_sort #(
      .DW  (8),
      .NUM (8),
      .MODE(1)
  ) dut1 (
      .*,
      .data_o(data_o_1)
  );

  initial begin
    data_q = new[8];
    foreach (data_q[i]) begin
      data_q[i] = $urandom();
      data_r[i*8+:8] = data_q[i];
    end

    #10 data_i <= data_r;

    #100 $finish();
  end

  //   initial begin
  //     $dumpfile("dump.vcd");
  //     $dumpvars(0, tb_bubble_sort);
  //   end


endmodule
