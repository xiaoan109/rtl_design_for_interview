// ---------------CRC校验-----------------------//
// G(x) = X^8+X^2+X+1;
module tb_crc8;

  reg clk;
  reg rst_n;
  reg data;
  reg [7:0]data8;
  reg enable;
  wire [7:0] crc_out;

  initial begin
    $fsdbDumpfile("crc8_1bit_tb.fsdb");
    $fsdbDumpvars(0);
  end

  initial begin
    clk = 0 ;
    forever begin
      #10 clk = ~clk;
    end
  end

  initial begin  
    rst_n= 0;
    #40 rst_n = 1; 
  end

  initial begin
    #1000;
    $display("%b",crc_out);
    $finish;
  end


  reg [15:0] data_reg = 16'habcd;
  // ---------------CRC校验单bit串行-----------------------//
  // initial begin
  //   data = 0;
  //   wait(rst_n);
  //   for (int i=0;i<16;i++)begin
  //     @(posedge clk)
  //       data<=data_reg[15-i];
  //       enable<=1;
  //   end
  //   @(posedge clk) 
  //     enable <=0;
  // end

  // crc8_1bit crc8_1bit_u(
  //  .clk(clk),
  //  .rst_n(rst_n),
  //  .data(data),
  //  .enable(enable),
  //  .crc_out(crc_out)
  // );


 // ---------------CRC校验单8bit并行-----------------------//
  initial begin
    data8 = 8'b0;
    wait(rst_n);
    @(posedge clk)
      data8<=data_reg[15:8];
      enable<=1;
    @(posedge clk)
      data8<=data_reg[7:0];
      enable<=1;
    @(posedge clk) 
      enable <=0;
  end
  
  crc8_8bit crc8_8bit_u(
   .clk(clk),
   .rst_n(rst_n),
   .data(data8),
   .enable(enable),
   .crc_out(crc_out)
  );


endmodule