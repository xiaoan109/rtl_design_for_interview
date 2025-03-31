module clk_switch(
    input               rstn ,
    input               clk1,
    input               clk2,
    input               sel_clk1 , // 1 clk1, 0 clk2
    output              clk_out
    );

   reg [2:0]            sel_clk1_r ;
   reg [1:0]            sel_clk1_neg_r ;
   reg [2:0]            sel_clk2_r ;
   reg [1:0]            sel_clk2_neg_r ;

   //使用3拍缓存，同步另一个时钟控制信号与本时钟控制信号的"与"逻辑操作
   always @(posedge clk1 or negedge rstn) begin
      if (!rstn) begin
         sel_clk1_r     <= 3'b111 ; //注意默认值
      end
      else begin
         //sel clk1, and not sel clk2
         sel_clk1_r     <= {sel_clk1_r[1:0], sel_clk1 & (!sel_clk2_neg_r[1])} ;
      end
   end

   //在下降沿，使用2拍缓存时钟选择信号
   always @(negedge clk1 or negedge rstn) begin
      if (!rstn) begin
         sel_clk1_neg_r <= 2'b11 ; //注意默认值
      end
      else begin
         sel_clk1_neg_r <= {sel_clk1_neg_r[0], sel_clk1_r[2]} ;
      end
   end

   //使用3拍缓存，同步另一个时钟控制信号与本时钟控制信号的"与"逻辑操作
   always @(posedge clk2 or negedge rstn) begin
      if (!rstn) begin
         sel_clk2_r     <= 3'b0 ; //注意默认值
      end
      else begin
         //sel clk2, and not sel clk1
         sel_clk2_r     <= {sel_clk2_r[1:0], !sel_clk1 & (!sel_clk1_neg_r[1])} ;
      end
   end

   //在下降沿，使用2拍缓存时钟选择信号
   always @(negedge clk2 or negedge rstn) begin
      if (!rstn) begin
         sel_clk2_neg_r <= 2'b0 ; //注意默认值
      end
      else begin
         sel_clk2_neg_r <= {sel_clk2_neg_r[0], sel_clk2_r[2]} ;
      end
   end

   //时钟逻辑运算时，一般使用特定的工艺单元库。
   //这里用 Verilog 自带的逻辑门单元代替
   wire clk1_gate, clk2_gate ;
   and (clk1_gate, clk1, sel_clk1_neg_r[1]) ;
   and (clk2_gate, clk2, sel_clk2_neg_r[1]) ;
   or  (clk_out, clk1_gate, clk2_gate) ;

endmodule
