`timescale 1ns/10ps
module tb_seq_det();

reg clk_i;
reg rst_ni;
reg data_i;
wire detected_o0; 
wire detected_o1;
wire detected_o2;
wire detected_o3;

seq_det #(
    .DETECT_WIDTH(5),
    .PATTERN(5'b10110),
    .OVERLAPPING(1)
) dut0 (
    .*,
    .detected_o(detected_o0)
);

seq_det #(
    .DETECT_WIDTH(5),
    .PATTERN(5'b10110),
    .OVERLAPPING(0)
) dut1 (
    .*,
    .detected_o(detected_o1)
);

seq_det_fsm dut2 (.*, .detected_o(detected_o2));

seq_det_fsm_onehot #(
    .DETECT_WIDTH(5),
    .PATTERN(5'b10110)
)dut3 (
    .*, 
    .detected_o(detected_o3)
);

always #5 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    rst_ni = 0;
    repeat(10) @(posedge clk_i);
    rst_ni = 1;
    repeat(1000) begin
        @(posedge clk_i);
        data_i = $urandom_range(0, 1);
    end
    $finish();
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
end

endmodule
