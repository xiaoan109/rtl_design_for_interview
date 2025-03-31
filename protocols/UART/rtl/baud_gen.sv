// divided by (dvsr+1)
// dvsr = sys_clk/(16*baudrate)-1
module baud_gen
  (
   input logic clk,
   input logic reset_n,
   input logic [10:0] dvsr,
   output logic tick
   );

   // declaration
   logic [10:0]	r_reg;
   logic [10:0]	r_next;

   // body
   // register
   always_ff @(posedge clk or negedge reset_n) begin
     if(~reset_n) begin
	r_reg <= 11'b0;
     end else begin
	r_reg <= r_next;
     end
   end

   // next-state logic
   assign r_next = (r_reg == dvsr) ? 11'b0 : r_reg + 11'b1;
   // output logic
   assign tick = (r_reg == 11'b1);

endmodule // baud_gen
