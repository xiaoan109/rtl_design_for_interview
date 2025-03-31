
`timescale 1ns / 10ps

module tb_pattern_det ();
  reg  [7:0] data_i;
  wire [7:0] data_o;

  pattern_det dut (.*);

  initial begin
    #10 data_i <= 8'b10010101;
    repeat (20) begin
      #10 data_i <= $urandom();
    end
    #10;
    $finish();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
