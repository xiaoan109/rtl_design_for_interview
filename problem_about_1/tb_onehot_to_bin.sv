`timescale 1ns / 10ps

module tb_onehot_to_bin ();

  reg  [7:0] onehot_i;
  wire [2:0] bin_o;
  reg  [7:0] rand_data_r;

  onehot_to_bin #(.ONEHOT_WIDTH(8)) dut (.*);


  initial begin
    repeat (20) begin
      #10 std::randomize(rand_data_r) with {$onehot(rand_data_r) == 1;};
      onehot_i <= rand_data_r;
    end
    #10;
    $finish();
  end

  always #10 begin
    $display("@%0t, onehot_i: %08b, bin_o: %0d", $time, onehot_i, bin_o);
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_onehot_to_bin);
  end
endmodule
