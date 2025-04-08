`timescale 1ns/10ps
module tb_rr_arbiter();
reg clk_i;
reg rst_ni;
reg [3:0] req_i;
wire [3:0] gnt_o;

rr_arbiter #(.NUM_REQ(4)) dut(.*);

always #5 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    rst_ni = 0;
    repeat(10) @(posedge clk_i);
    rst_ni <= 1;
    req_i <= 4'b0001;
    repeat(20) begin
        @(posedge clk_i);
        req_i <= $urandom();
    end
    $finish();
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
end



endmodule
