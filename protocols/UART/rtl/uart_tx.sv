module uart_tx
  #(
    parameter DBIT = 8,
    parameter SB_TICK = 16
    )
   (
    input logic clk,
    input logic reset_n,
    input logic tx_start,
    input logic s_tick,
    input logic [7:0] din,
    output logic tx_done_tick,
    output logic tx
    );

   // fsm state type
   typedef enum	 {idle, start, data, stop} state_type;

   // signal declaration
   state_type state_reg;
   state_type state_next;
   logic [3:0]	 s_reg;
   logic [3:0]	 s_next;
   logic [2:0]	 n_reg;
   logic [2:0]	 n_next;
   logic [7:0]	 b_reg;
   logic [7:0]	 b_next;
   logic	 tx_reg;
   logic	 tx_next;

   // body
   // FSMD state & data registers
   always_ff @(posedge clk or negedge reset_n) begin
      if(~reset_n) begin
	 state_reg <= idle;
	 s_reg <= 4'b0;
	 n_reg <= 3'b0;
	 b_reg <= 8'b0;
	 tx_reg <= 1'b1;
      end else begin
	 state_reg <= state_next;
	 s_reg <= s_next;
	 n_reg <= n_next;
	 b_reg <= b_next;
	 tx_reg <= tx_next;
      end // else: !if(~reset_n)
   end // always_ff @ (posedge clk or negedge reset_n)

   // FSMD next-state logic & functional units
   always_comb begin
      state_next = state_reg;
      tx_done_tick = 1'b0;
      s_next = s_reg;
      n_next = n_reg;
      b_next = b_reg;
      tx_next = tx_reg;
      case(state_reg)
	idle: begin
	   tx_next = 1'b1;
	   if(tx_start) begin
	      state_next = start;
	      s_next = 4'b0;
	      b_next = din;
	   end
	end
	start: begin
	   tx_next = 1'b0;
	   if(s_tick) begin
	      if(s_reg == 4'd15) begin
		 state_next = data;
		 s_next = 4'b0;
		 n_next = 3'b0;
	      end else begin
		 s_next = s_reg + 4'b1;
	      end
	   end
	end // case: start
	data: begin
	   tx_next = b_reg[0];
	   if(s_tick) begin
	      if(s_reg == 4'd15) begin
		 s_next = 4'b0;
		 b_next = b_reg >> 1;
		 if(n_reg == DBIT - 3'b1) begin
		    state_next = stop;
		 end else begin
		    n_next = n_reg + 3'b1;
		 end
	      end else begin
		 s_next = s_reg + 4'b1;
	      end // else: !if(s_reg == 4'd15)
	   end // if (s_tick)
	end // case: data
	stop: begin
	   tx_next = 1'b1;
	   if(s_tick) begin
	      if(s_reg == SB_TICK - 4'b1) begin
		 state_next = idle;
		 tx_done_tick = 1'b1;
	      end else begin
		 s_next = s_reg + 4'b1;
	      end
	   end
	end // case: stop
      endcase // case (state_reg)
   end // always_comb

   // output
   assign tx = tx_reg;
endmodule // uart_tx

		 
	      
		   
	 
	 

	 
	 
