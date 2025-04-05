//时间单位、时间精度
`timescale 1ns/1ps

module  tb_async_fifo();

    //重定义时钟周期
    parameter CLK_CYCLE = 20;

    //激励信号定义
    reg         tb_wclk     ;
    reg         tb_rclk     ;
    reg         tb_wrst_n   ;
    reg         tb_rrst_n   ;
    reg         wr_en       ;
    reg         rd_en       ;
    reg [7:0]   wr_data     ;

    //产生时钟信号
    always #(CLK_CYCLE/2) tb_wclk = ~tb_wclk; //写时钟
    always #(CLK_CYCLE/4) tb_rclk = ~tb_rclk; //读时钟

    //时钟和复位的激励信号
    initial begin
        tb_wclk = 1'b1;
        tb_rclk = 1'b1;
        tb_wrst_n = 1'b0;
        tb_rrst_n = 1'b0;
        wr_en  = 'd0;
        rd_en  = 'd0;
        wr_data= 'd0;
        #(CLK_CYCLE*5);
        tb_wrst_n = 1'b1;
        tb_rrst_n = 1'b1;
        //模拟五次写操作
        repeat(5) begin
            wr_en = 1'b1;
            wr_data = $random;
            #CLK_CYCLE;
            wr_en = 1'b0;
            #CLK_CYCLE;
        end
        //模拟五次读操作
        #(CLK_CYCLE*5);
        repeat(5)begin
            rd_en = 1'b1;
            #(CLK_CYCLE/2);
            rd_en = 1'b0;
            #(CLK_CYCLE/2);
        end

        #(CLK_CYCLE*10);
        $stop;
    end
    //模块实例化
    async_fifo  async_fifo_inst(
        /* input                    */ .wr_clk_i   (tb_wclk     ), //写时钟
        /* input                    */ .wr_rst_ni  (tb_wrst_n   ), //写侧复位信号，低有效
        /* input                    */ .rd_clk_i   (tb_rclk     ), //读时钟
        /* input                    */ .rd_rst_ni  (tb_rrst_n   ), //读侧复位信号，低有效              
        /* input                    */ .push_i     (wr_en       ), //写使能
        /* input   [DATA_W-1:0]     */ .data_i     (wr_data     ), //写数据输入
        /* output                   */ .full_o     (            ), //写侧满信号                      
        /* input                    */ .pop_i      (rd_en       ), //读使能
        /* output  [DATA_W-1:0]     */ .data_o     (            ), //读数据输出       
        /* output                   */ .empty_o    (            )  //读侧空信号     
    );
endmodule