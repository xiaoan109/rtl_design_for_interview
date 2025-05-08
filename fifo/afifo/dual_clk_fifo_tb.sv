`timescale 1 ns / 1 ps

module dual_clk_fifo_tb;

    parameter DATESIZE = 8;
    parameter ADDRSIZE = 3;
    parameter ALMOST_GAP = 1; 
    reg [DATESIZE-1:0]wdata;
    reg wrst_n;
    reg winc;
    reg rinc;
    reg wclk;
    reg rclk;
    reg rrst_n;
    wire [DATESIZE-1:0]rdata;
    wire wfull;
    wire rempty;
    wire almost_empty;
    wire almost_full;

    reg [3:0]a;
    reg [3:0]b;
    reg [4:0]c;
    reg x;
    initial begin
        $dumpfile("dual_clk_fifo_tb.vcd");
        $dumpvars;
        wdata = 0;
        wrst_n = 0;
        rinc = 0;
        rclk = 0;
        rrst_n = 0;
        wclk = 0;
        winc = 0;
    

        #2;wrst_n = 0; rrst_n = 0;
        #4;wrst_n = 1; rrst_n = 1;
     
        #100;
        $finish();

    end
 always @(posedge wclk or wrst_n)begin
    if( wrst_n == 1'b0 )begin 
        winc = 1'b0;
    end 
    else if( wfull )
        winc = 1'b0;
    else 
        winc = 1'b1 ;
end 
    
// rinc generate    
always @(posedge rclk or rrst_n)begin
    if( rrst_n == 1'b0 )begin
        rinc = 1'b0 ;
    end 
    else if( rempty )
        rinc = 1'b0;
    else 
        rinc = 1'b1 ;
end 

// wdata 
always @(posedge wclk or negedge wrst_n)begin
    if( wrst_n == 1'b0 )begin
        wdata = 0 ;
    end  
    else if( winc )begin 
        wdata = wdata + 1'b1;
    end 
end 

    always #0.5 wclk = ~wclk;
    always #2   rclk = ~rclk;


dual_clk_fifo #(
    .DATESIZE                       ( DATESIZE     ),
    .ADDRSIZE                       ( ADDRSIZE     ),
    .ALMOST_GAP                     ( ALMOST_GAP   )
U_DUAL_CLK_FIFO_0(
    .wdata                          ( wdata ),
    .winc                           ( winc  ),
    .wclk                           ( wclk  ),
    .wrst_n                         ( wrst_n),
    .rinc                           ( rinc  ),
    .rclk                           ( rclk  ),
    .rrst_n                         ( rrst_n),
    .rdata                          ( rdata ),
    .wfull                          ( wfull ),
    .rempty                         ( rempty),
    .almost_empty              (almost_empty),
    .almost_full                (almost_full)
);


endmodule



