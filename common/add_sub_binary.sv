module add_sub_binary #(
	parameter WORD_WIDTH = 0
) (
	input wire add_sub_i,  // 0/1 -> +/-
	input wire carry_in_i,
	input wire [WORD_WIDTH-1:0] A_i,
	input wire [WORD_WIDTH-1:0] B_i,
	output wire [WORD_WIDTH-1:0] sum_o,
	output wire carry_out_o,
	output wire [WORD_WIDTH-1:0] carries_o,
	output wire overflow_o
);
	
	
	// extend the carry in
	wire [WORD_WIDTH-1:0] carry_in_ext_unsigned_w;
	wire [WORD_WIDTH-1:0] carry_in_ext_signed_w;
	
	width_adjuster #(
		.WORD_WIDTH_IN(1),
		.SIGNED(0),
		.WORD_WIDTH_OUT(WORD_WIDTH)
	) ext_carry_in_unsigned (
		.original_i(carry_in_i),
		.adjusted_o(carry_in_ext_unsigned_w)
	);
		
	width_adjuster #(
		.WORD_WIDTH_IN(1),
		.SIGNED(1),
		.WORD_WIDTH_OUT(WORD_WIDTH)
	) ext_carry_in_signed (
		.original_i(carry_in_i),
		.adjusted_o(carry_in_ext_signed_w)
	);
	
	// select add or sub
	// A-B = A + (~B + 1)
	wire [WORD_WIDTH-1:0] B_sel_w;
	wire [WORD_WIDTH-1:0] negation_offset_w;
	wire [WORD_WIDTH-1:0] carry_in_sel_w;
	
	assign B_sel_w = add_sub_i ? ~B_i : B_i;
	assign negation_offset_w = add_sub_i ? 1 : 0;
	assign carry_in_sel_w = add_sub_i ? carry_in_ext_signed_w : carry_in_ext_unsigned_w;
	
	// adder
	assign {carry_out_o, sum_o} = A_i + B_sel_w + negation_offset_w + carry_in_sel_w;
	
	// overflow calculate
	
	carry_in_binary #(
		.WORD_WIDTH(WORD_WIDTH)
	) per_bit (
		.A_i(A_i),
		.B_i(B_i),
		.sum_i(sum_o),
		.carry_in_o(carries_o)
	);
	
	assign overflow_o = carries_o[WORD_WIDTH-1] != carry_out_o;
	
endmodule