module cdc_slow2fast (
    input  wire clk1_i,
    input  wire rst1_ni,
    input  wire data_i,
    input  wire clk2_i,
    input  wire rst2_ni,
    output wire data_o
);
  // assume that data_r is sampled from data_i
  reg data_r;
  always @(posedge clk1_i or negedge rst1_ni) begin
    if (~rst1_ni) begin
      data_r <= 1'b0;
    end else begin
      data_r <= data_i;
    end
  end


  // back to back
  reg data_r1;
  reg data_r2;
  always @(posedge clk2_i or negedge rst2_ni) begin
    if (~rst2_ni) begin
      data_r1 <= 1'b0;
      data_r2 <= 1'b0;
    end else begin
      data_r1 <= data_r;
      data_r2 <= data_r1;
    end
  end

  // edge detect
  reg data_r3;

  always @(posedge clk2_i or negedge rst2_ni) begin
    if (~rst2_ni) begin
      data_r3 <= 1'b0;
    end else begin
      data_r3 <= data_r2;
    end
  end

  assign data_o = ~data_r3 & data_r2;

endmodule
