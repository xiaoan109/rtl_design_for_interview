//  8bit并行的矩阵由串行的输入而来从小到大的独热码输入对应的
//  example:  0000_0001 -----> CRC 0 0 0 0_0 1 1 1 
//            0000_0010 -----> CRC 0 0 0 0_1 1 1 0     ----------------
//            0000_0100 -----> CRC 0 0 0 1_1 1 0 0     |   纵向为系数   |
//            0000_1000 -----> CRC 0 0 1 1_1 0 0 0     |               |
//            0001_0000 -----> CRC 0 1 1 1_0 0 0 0     |               |
//            0010_0000 -----> CRC 1 1 1 0_0 0 0 0     |               |
//            0100_0000 -----> CRC 1 1 0 0_0 1 1 1     |               |
//            1000_0000 -----> CRC 1 0 0 0_1 0 0 1     ----------------
//                          crc_in 7 6 5 4 3 2 1 0                  
module crc8_8bit(
  input clk,
  input rst_n,
  input [7:0] data,
  input enable,
  output reg [7:0] crc_out
);

  reg [7:0] crc_in;
  //  根据系数选择data 和 crc_out的对应bit位
  always@(*)begin
    crc_in[0] = data[0]^data[6]^data[7]^crc_out[0]^crc_out[6]^crc_out[7];
    crc_in[1] = data[0]^data[1]^data[6]^crc_out[0]^crc_out[1]^crc_out[6];
    crc_in[2] = data[0]^data[1]^data[2]^data[6]^crc_out[0]^crc_out[1]^crc_out[2]^crc_out[6];
    crc_in[3] = data[1]^data[2]^data[3]^data[7]^crc_out[1]^crc_out[2]^crc_out[3]^crc_out[7];
    crc_in[4] = data[2]^data[3]^data[4]^crc_out[2]^crc_out[3]^crc_out[4];
    crc_in[5] = data[3]^data[4]^data[5]^crc_out[3]^crc_out[4]^crc_out[5];
    crc_in[6] = data[4]^data[5]^data[6]^crc_out[4]^crc_out[5]^crc_out[6];
    crc_in[7] = data[5]^data[6]^data[7]^crc_out[5]^crc_out[6]^crc_out[7];
  end

  always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      crc_out <= 8'b0;
    end else if(enable) begin
      crc_out <= crc_in;
    end
  end

endmodule