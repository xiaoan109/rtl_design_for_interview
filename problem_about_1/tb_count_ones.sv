`timescale 1ns / 10ps

module tb_count_ones ();

  reg  [7:0] data_i;
  wire [2:0] count_o;

  count_ones #(.DW(8)) dut (.*);




  initial begin
    repeat (20) begin
      #10 data_i <= $urandom();
    end
    #10;
    $finish();
  end

  always #10 begin
    $display("@%0t, data_i: %08b, count_o: %0d", $time, data_i, count_o);
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_count_ones);
  end
endmodule
