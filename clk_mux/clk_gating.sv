module clk_gating(
  input wire clk_i,
  input wire en_i,
  output wire clk_o
);

  reg clk_en;

  always @(*) begin
    if(~clk_i) clk_en = en_i;
  end

  assign clk_o = clk_i && clk_en;
  
endmodule
