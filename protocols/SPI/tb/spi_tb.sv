`timescale 1ns/10ps
module spi_tb();
  bit clk;
  bit reset_n;
  bit [7:0] din;
  bit [15:0] dvsr;
  bit start;
  bit cpol;
  bit cpha;
  wire [7:0] dout;
  wire spi_done_tick;
  wire ready;
  wire sclk;
  wire miso;
  wire mosi;

  spi spi_unit(.*);
  assign miso = mosi;

  always #5 clk = ~clk;
  
  initial begin
    reset_n = 1'b1;
    din = 8'b0;
    dvsr = 16'd999; //50KHz spi clk with 100MHz sys clk
    start = 1'b0;
    cpol = 1'b0;
    cpha = 1'b0;
    repeat(2) @(posedge clk);
    reset_n = 1'b0;
    repeat(10) @(posedge clk);
    reset_n = 1'b1;
    repeat(2) @(posedge clk);
    wait(ready);
    start = 1'b1;
    din = 8'h55;
    @(posedge clk);
    start = 1'b0;
    wait(spi_done_tick);
    repeat(10) @(posedge clk);
    $stop;
  end
endmodule
