`timescale 1ns/10ps
module tb_clk_divider();

reg clk;
reg nrst;
reg ena;
wire [31:0] out;

clk_divider #(
    .WIDTH(32)
) dut (.*);

always #5 clk = ~clk;

initial begin
    clk = 0;
    nrst = 0;
    ena = 0;
    repeat(10) @(posedge clk);
    nrst = 1;
    ena = 1;
    repeat(100) @(posedge clk);
    $finish();
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
end

endmodule
