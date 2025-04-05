module rstgen #(
  parameter NumRegs = 4
) (
  input  wire clk_i,
  input  wire rst_ni,
  output wire rst_no,
  output wire init_no
);
  // internal reset
  reg [NumRegs-1:0] synch_regs_q;

  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      synch_regs_q <= 0;
    end else begin
      synch_regs_q <= {synch_regs_q[NumRegs-2:0], 1'b1};
    end
  end

  assign rst_no = synch_regs_q[NumRegs-1];
  assign init_no = synch_regs_q[NumRegs-1];

endmodule
