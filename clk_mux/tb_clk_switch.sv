`timescale 1ns/10ps

module tb_clk_switch();
  reg clk1;
  reg clk2;
  reg rstn;
  reg sel_clk1;
  wire clk_out;

  clk_switch dut(.*);

  always #5 clk1 = ~clk1;
  always #10 clk2 = ~clk2;

  initial begin
    clk1 = 0;
    clk2 = 0;
    rstn = 0;
    sel_clk1 = 0;
    #100 rstn = 1;
    #100 sel_clk1 = 1;
    #1000 sel_clk1 = 0;
    #1000 $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end

endmodule
