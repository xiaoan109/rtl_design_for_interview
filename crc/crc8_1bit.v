//---------------CRC校验-----------------------//
// G(x) = X^8+X^2+X+1;
module crc8_1bit(
  input clk,
  input rst_n,
  input data,
  input enable,
  output reg [7:0] crc_out
);

  reg [7:0] crc_in;
  always@(*)begin
    crc_in[0] = crc_out[7]^data;
    crc_in[1] = crc_out[0]^crc_in[0];
    crc_in[2] = crc_out[1]^crc_in[0];
    crc_in[3] = crc_out[2];
    crc_in[4] = crc_out[3];
    crc_in[5] = crc_out[4];
    crc_in[6] = crc_out[5];
    crc_in[7] = crc_out[6];
  end

  always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      crc_out <= 8'b0;
    end else if(enable) begin
      crc_out <= crc_in;
    end
  end

endmodule