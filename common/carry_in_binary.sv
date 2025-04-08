module carry_in_binary #(
	parameter WORD_WIDTH = 0
) (
	input wire [WORD_WIDTH-1:0] A_i,
	input wire [WORD_WIDTH-1:0] B_i,
	input wire [WORD_WIDTH-1:0] sum_i,
	output wire [WORD_WIDTH-1:0] carry_in_o
);
	
	assign carry_in_o = A_i ^ B_i ^ sum_i;

endmodule