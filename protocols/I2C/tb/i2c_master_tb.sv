`timescale 1ns/10ps
module i2c_master_tb();
   localparam START_CMD   =3'b000;
   localparam WR_CMD      =3'b001;
   localparam RD_CMD      =3'b010;
   localparam STOP_CMD    =3'b011;
   localparam RESTART_CMD =3'b100;

   bit clk;
   bit reset_n;
   bit [7:0] din;
   bit [15:0] dvsr; // dvsr = sys_freq/(4*i2c_freq)
   bit [2:0]  cmd;
   bit	      wr_i2c;
   wire	      scl;
   wire	      sda;
   wire	      ready;
   wire	      done_tick;
   wire	      ack;
   wire [7:0] dout;

   i2c_master i2c_master_unit (.*);
   pullup(scl);
   pullup(sda);

   // simulate i2c slave
   logic      sda_slave;
   logic [3:0] slave_count;
   always_ff @(posedge scl or negedge reset_n or posedge ready) begin
      if(~reset_n || ready) begin
	 sda_slave <= 1'b1;
	 slave_count <= 4'b0;
      end else begin
	 if(slave_count == 4'd8) begin
	    slave_count <= 4'b0;
	    sda_slave <= 1'b0;
	 end else begin
	    slave_count <= slave_count + 4'b1;
	    sda_slave <= 1'b1;
	 end
      end // else: !if(~reset_n)
   end // always_ff @ (posedge scl or negedge reset_n)

   assign sda = sda_slave ? 1'bz : 1'b0;
   
	 

   
   
   
   always #5 clk = ~clk;
   
   initial begin
      reset_n = 1'b1;
      din = 8'b0;
      dvsr = 16'd250; //100MHz sys clk with 100KHz i2c clk
      cmd = START_CMD;
      wr_i2c = 1'b0;
      repeat(2) @(posedge clk);
      reset_n = 1'b0;
      repeat(10) @(posedge clk);
      reset_n = 1'b1;
      i2c_write_byte(8'h55);
      i2c_write_byte(8'haa);
      repeat(10) @(posedge clk);
      $stop;
   end // initial begin


   task i2c_write_byte(logic [7:0] data);
      wait(ready); //send START_CMD
      wr_i2c = 1'b1;
      cmd = START_CMD;
      @(posedge clk);
      wr_i2c = 1'b0;
      @(posedge clk);
      wait(ready); //send WR_CMD and data
      wr_i2c = 1'b1;
      cmd = WR_CMD;
      din = data;
      @(posedge clk);
      wr_i2c = 1'b0;
      @(posedge clk);
      wait(ready); //send STOP_CMD and data
      wr_i2c = 1'b1;
      cmd = STOP_CMD;
      @(posedge clk);
      wr_i2c = 1'b0;
      @(posedge clk);
      wait(ready); // wait fsm idle
   endtask // i2c_write_byte
   
      
endmodule // i2c_master_tb

