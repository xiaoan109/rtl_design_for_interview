`timescale 1ns/10ps

module tb_clk_mux();
  reg [3:0] clks_i;
  reg async_rstn_i;
  reg [1:0] async_sel_i;
  wire clk_o;

  clk_mux #(
    .NUM_INPUTS(4),
    .NUM_SYNC_STAGES(2),
    .CLOCK_DURING_RESET(0)
  ) dut (.*);

  always #5 clks_i[0] = ~clks_i[0];
  always #10 clks_i[1] = ~clks_i[1];
  always #20 clks_i[2] = ~clks_i[2];
  always #30 clks_i[3] = ~clks_i[3];

  initial begin
    clks_i = '0;
    async_rstn_i = 0;
    async_sel_i = 0;
    #100 async_rstn_i = 1;
    #1000 async_sel_i = 1;
    #1000 async_sel_i = 2;
    #1000 async_sel_i = 3;
    #1000 $finish();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end

endmodule
