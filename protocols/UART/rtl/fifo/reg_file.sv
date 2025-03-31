module reg_file
  #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 2
    )
   (
    input logic clk,
    input logic wr_en,
    input logic [ADDR_WIDTH-1:0] w_addr,
    input logic [ADDR_WIDTH-1:0] r_addr,
    input logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data
    );

   // signal declaration
   logic [DATA_WIDTH-1:0]	  array_reg [0: 2**ADDR_WIDTH-1];

   // body
   // write operation
   always_ff @(posedge clk) begin
      if(wr_en) begin
	 array_reg[w_addr] <= w_data;
      end
   end

   // read operation
   assign r_data = array_reg[r_addr];
endmodule 
   
   
