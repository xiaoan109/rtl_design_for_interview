module fifo
  #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
    )
   (
    input logic clk,
    input logic reset_n,
    input logic rd,
    input logic wr,
    input logic [DATA_WIDTH-1:0] w_data,
    output logic empty,
    output logic full,
    output logic [DATA_WIDTH-1:0] r_data
    );


   // signal declaration
   logic [ADDR_WIDTH-1:0]	  w_addr;
   logic [ADDR_WIDTH-1:0]	  r_addr;
   logic			  wr_en;
   logic			  full_tmp;

   // body
   // write enabled only when FIFO is not full
   assign wr_en = wr & ~full_tmp;
   assign full = full_tmp;
   
   // instantiate fifo control unit
   fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
     (.*, .full(full_tmp));

   // instantiate register file
   reg_file
     #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) f_unit (.*);
endmodule // fifo
