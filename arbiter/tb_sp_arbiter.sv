`timescale 1ns/10ps
module tb_sp_arbiter();
reg [3:0] req_i;
wire [3:0] gnt_o0;
wire [3:0] gnt_o1;

sp_arbiter #(
    .NUM(4),
    .LSB_HIGH(1)
) dut0 (.req_i(req_i), .gnt_o(gnt_o0));

sp_arbiter #(
    .NUM(4),
    .LSB_HIGH(0)
) dut1 (.req_i(req_i), .gnt_o(gnt_o1));

initial begin
    req_i = 4'b0001;
    repeat(20) begin
        #10 req_i = $urandom();
    end
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
end

endmodule
