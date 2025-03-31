`timescale 1ns / 10ps

module tb ();

  reg  clk1_i;
  reg  rst1_ni;
  reg  clk2_i;
  reg  rst2_ni;
  reg  data_i;
  wire data_o;
  wire cdc_busy;

  cdc_fast2slow dut (.*);

  always #5 clk1_i = ~clk1_i;
  always #10 clk2_i = ~clk2_i;

  initial begin
    clk1_i  = 0;
    clk2_i  = 0;
    rst1_ni = 0;
    rst2_ni = 0;

    data_i  = 0;

    fork
      begin
        repeat (10) @(posedge clk1_i);
        rst1_ni = 1;
      end
      begin
        repeat (10) @(posedge clk2_i);
        rst2_ni = 1;
      end
    join

    repeat (100) begin
      @(posedge clk1_i);
      while(cdc_busy) @(posedge clk1_i);
      data_i = $urandom_range(0, 1);
    end

    $finish();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end


endmodule
