module counter_binary #(
	parameter WORD_WIDTH = 0,
	parameter [WORD_WIDTH-1:0] INCREMENT = 0,
	parameter [WORD_WIDTH-1:0] INITIAL_COUNT = 0
) (
	input wire clk_i,
	input wire rst_ni,
	input wire up_down_i, // 0/1 -> up/down
	input wire run_i,
	input wire load_i,
	input wire [WORD_WIDTH-1:0] load_count_i,
	input wire carry_in_i,
	output wire carry_out_o,
	output wire [WORD_WIDTH-1:0] carries_o,
	output wire overflow_o,
	output wire [WORD_WIDTH-1:0] count_o
);
	
	wire [WORD_WIDTH-1:0] count_w;
	wire carry_out_w;
	wire [WORD_WIDTH-1:0] carries_w;
	wire overflow_w;
	
	add_sub_binary #(
		.WORD_WIDTH(WORD_WIDTH)
	) calc_next_count (
		.add_sub_i(up_down_i),
		.carry_in_i(carry_in_i),
		.A_i(count_o),
		.B_i(INCREMENT),
		.sum_o(count_w),
		.carry_out_o(carry_out_w),
		.carries_o(carries_w),
		.overflow_o(overflow_w)
	);
	
	wire [WORD_WIDTH-1:0] next_count_w;
	wire load_counter_w;
	wire clear_flags_w;
	
	assign next_count_w = load_i ? load_count_i : count_w;
	assign load_counter_w = run_i || load_i;
	assign rst_flags_w = ~load_i || rst_ni;
	
	register #(
		.WORD_WIDTH(WORD_WIDTH),
		.RESET_VALUE(INITIAL_COUNT)
	) count_storage (
		.clk_i(clk_i),
		.clk_en_i(load_counter_w),
		.rst_ni(rst_ni),
		.data_i(next_count_w),
		.data_o(count_o)
	);
	
	register #(
		.WORD_WIDTH(WORD_WIDTH),
		.RESET_VALUE(0)
	) carries_storage (
		.clk_i(clk_i),
		.clk_en_i(run_i),
		.rst_ni(rst_flags_w),
		.data_i(carries_w),
		.data_o(carries_o)
	);
	
	register #(
		.WORD_WIDTH(1),
		.RESET_VALUE(0)
	) carry_out_storage (
		.clk_i(clk_i),
		.clk_en_i(run_i),
		.rst_ni(rst_flags_w),
		.data_i(carry_out_w),
		.data_o(carry_out_o)
	);
	
	register #(
		.WORD_WIDTH(1),
		.RESET_VALUE(0)
	) overflow_storage (
		.clk_i(clk_i),
		.clk_en_i(run_i),
		.rst_ni(rst_flags_w),
		.data_i(overflow_w),
		.data_o(overflow_o)
	);
	
	
	

endmodule