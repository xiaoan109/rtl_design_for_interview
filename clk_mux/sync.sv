module sync #(
    parameter STAGES = 2,
    parameter ResetValue = 1'b0
) (
    input  wire clk_i,
    input  wire rst_ni,
    input  wire serial_i,
    output wire serial_o
);

   (* dont_touch = "true" *)
   (* async_reg = "true" *)
   reg [STAGES-1:0] reg_q;

    always @(posedge clk_i, negedge rst_ni) begin
        if (!rst_ni) begin
            reg_q <= {STAGES{ResetValue}};
        end else begin
            reg_q <= {reg_q[STAGES-2:0], serial_i};
        end
    end

    assign serial_o = reg_q[STAGES-1];

endmodule
