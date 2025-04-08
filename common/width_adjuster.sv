module width_adjuster #(
	parameter WORD_WIDTH_IN = 0,
	parameter SIGNED = 0,
	parameter WORD_WIDTH_OUT = 0
) (
	input wire [WORD_WIDTH_IN-1:0] original_i,
	output wire [WORD_WIDTH_OUT-1:0] adjusted_o
);

	localparam PAD_WIDTH = WORD_WIDTH_OUT - WORD_WIDTH_IN;
	
	generate
		if(PAD_WIDTH == 0) begin : zero
			assign adjusted_o = original_i;
		end else if(PAD_WIDTH > 0) begin : sign_extend
			localparam PAD_ZERO = {PAD_WIDTH{1'b0}};
			localparam PAD_ONES = {PAD_WIDTH{1'b1}};
			assign adjusted_o = ((SIGNED != 0) && (original_i[WORD_WIDTH_IN-1] == 1'b1)) ? {PAD_ONES, original_i} : {PAD_ZERO, original_i};
		end else if(PAD_WIDTH < 0) begin: truncate
			assign adjusted_o = original_i[WORD_WIDTH_OUT-1:0];
		end
	endgenerate

endmodule