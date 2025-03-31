`timescale 1ns/10ps

module clk_int_div_tb();
  reg clk_i;
  reg rst_ni;
  reg en_i;
  reg [3:0] div_i;
  reg div_valid_i;
  wire div_ready_o;
  wire clk_o;

  clk_int_div #(
    .DIV_VALUE_WIDTH(4),
    .DEFAULT_DIV_VALUE(0),
    .ENABLE_CLOCK_IN_RESET(1'b0)
  ) dut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .en_i(en_i),
    .test_mode_en_i(1'b0),
    .div_i(div_i),
    .div_valid_i(div_valid_i),
    .div_ready_o(div_ready_o),
    .clk_o(clk_o)
  );

  always #5 clk_i = ~clk_i;

  initial begin
    clk_i = 0;
    rst_ni = 1;
    en_i = 0;
    div_i = 0;
    div_valid_i = 0;
    repeat(2) @(posedge clk_i);
    rst_ni <= 0;
    repeat(10) @(posedge clk_i);
    rst_ni <= 1;
    en_i <= 1;
    repeat(20) @(posedge clk_i); // bypass
    set_div(4);
    repeat(50) @(posedge clk_i); // clk divide by 4
    set_div(7);
    repeat(50) @(posedge clk_i); // clk divide by 7
    en_i <= 0;  // gated clock
    repeat(20) @(posedge clk_i);
    $finish();
  end

  task set_div(input reg [3:0] div);
    begin
      @(posedge clk_i);
      div_i <= div;
      div_valid_i <= 1;
      @(posedge clk_i);
      while(~div_ready_o) @(posedge clk_i);
      div_valid_i <= 0;
    end
  endtask


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end


endmodule
