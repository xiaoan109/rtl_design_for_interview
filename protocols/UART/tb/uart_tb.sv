`timescale 1ns/10ps
module uart_tb();
   parameter DBIT = 8;
   parameter SB_TICK = 16;
   parameter FIFO_W = 2;
   parameter DIV_115200_100M = 53;
   

   bit	     clk;
   bit	     reset_n;
   bit	     rd_uart;
   bit	     wr_uart;
   wire	     rx;
   bit [7:0] w_data;
   bit [10:0] dvsr;
   wire	      tx_full;
   wire	      rx_empty;
   wire	      tx;
   wire [7:0] r_data;

   uart #(.DBIT(DBIT), .SB_TICK(SB_TICK), .FIFO_W(FIFO_W)) uart_unit
     (.*);
   assign rx = tx; // loopback 

   always #5 clk = ~clk;

   initial begin
      reset_n = 1'b1;
      rd_uart = 1'b0;
      wr_uart = 1'b0;
      w_data = 8'b0;
      dvsr = 11'b0;
      repeat(2) @(posedge clk);
      reset_n = 1'b0;
      repeat(10) @(posedge clk);
      reset_n = 1'b1;
      repeat(2) @(posedge clk);
      dvsr = DIV_115200_100M;
      repeat(2) @(posedge clk);
      wait(!tx_full);
      wr_uart = 1'b1;
      w_data = 8'h55;
      @(posedge clk);
      w_data = 8'haa;
      @(posedge clk);
      wr_uart = 1'b0;
      repeat(2) begin
	 wait(!rx_empty);
	 rd_uart = 1'b1;
	 @(posedge clk);
	 rd_uart = 1'b0;
	 @(posedge clk);
      end
      repeat(10) @(posedge clk);
      $stop;
   end // initial begin

endmodule // uart_tb

      
   
