module fifo_ctrl
  #(
    parameter ADDR_WIDTH = 4
    )
   (
    input logic clk,
    input logic reset_n,
    input logic rd,
    input logic wr,
    output logic empty,
    output logic full,
    output logic [ADDR_WIDTH-1:0] w_addr,
    output logic [ADDR_WIDTH-1:0] r_addr
    );

   // signal declaration
   logic [ADDR_WIDTH-1:0]	  w_ptr_logic;
   logic [ADDR_WIDTH-1:0]	  w_ptr_next;
   logic [ADDR_WIDTH-1:0]	  w_ptr_succ;
   logic [ADDR_WIDTH-1:0]	  r_ptr_logic;
   logic [ADDR_WIDTH-1:0]	  r_ptr_next;
   logic [ADDR_WIDTH-1:0]	  r_ptr_succ;
   logic			  full_logic;
   logic			  empty_logic;
   logic			  full_next;
   logic			  empty_next;

   // body
   // fifo control logic
   // logicisters for status and read and write pointers
   always_ff @(posedge clk or negedge reset_n) begin
      if(~reset_n) begin
	 w_ptr_logic <= 0;
	 r_ptr_logic <= 0;
	 full_logic <= 1'b0;
	 empty_logic <= 1'b1;
      end else begin
	 w_ptr_logic <= w_ptr_next;
	 r_ptr_logic <= r_ptr_next;
	 full_logic <= full_next;
	 empty_logic <= empty_next;
      end // else: !if(~reset_n)
   end // always_ff @ (posedge clk or negedge reset_n)

   // next-state logic for read and write pointers
   always_comb begin
      // successive pointer values
      w_ptr_succ = w_ptr_logic + 1;
      r_ptr_succ = r_ptr_logic + 1;
      // default: keep old values
      w_ptr_next = w_ptr_logic;
      r_ptr_next = r_ptr_logic;
      full_next = full_logic;
      empty_next = empty_logic;
      unique case ({wr, rd})
	2'b01: begin // read
	  if(~empty_logic) begin // not empty
	     r_ptr_next = r_ptr_succ;
	     full_next = 1'b0;
	     if(r_ptr_succ == w_ptr_logic) begin
		empty_next = 1'b1;
	     end
	  end
	end
	2'b10: begin // write
	  if(~full_logic) begin // not full
	     w_ptr_next = w_ptr_succ;
	     empty_next = 1'b0;
	     if(w_ptr_succ == r_ptr_logic) begin
		full_next = 1'b1;
	     end
	  end
	end
	2'b11: begin // write and read
	   w_ptr_next = w_ptr_succ;
	   r_ptr_next = r_ptr_succ;
	end
	default: ; // 2'b00; null statement; no op
      endcase // unique case ({wr, rd})
   end // always_comb

   // output
   assign w_addr = w_ptr_logic;
   assign r_addr = r_ptr_logic;
   assign full = full_logic;
   assign empty = empty_logic;
endmodule // fifo_ctrl

   
