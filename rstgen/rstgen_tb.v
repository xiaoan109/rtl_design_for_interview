`timescale 1ns/10ps

module rstgen_tb();
  reg clk_i;
  reg rst_ni;
  wire rst_no;
  wire init_no;

  rstgen #(
    .NumRegs(2)
  ) dut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .rst_no(rst_no),
    .init_no(init_no)
  );

  always #5 clk_i = ~clk_i;

  initial begin
    clk_i = 0;
    rst_ni = 1;
    repeat(2) @(posedge clk_i);
    rst_ni = 0;
    repeat(10) @(posedge clk_i);
    rst_ni = 1;
    repeat(2) @(posedge clk_i);
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end

endmodule
