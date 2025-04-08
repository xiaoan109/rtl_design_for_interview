module serial_parallel #(
	parameter WORD_WIDTH = 0
) (
	input wire clk_i,
	input wire clk_en_i,
	input wire rst_ni,
	output wire parallel_valid_o,
	input wire parallel_ready_i,
	output wire [WORD_WIDTH-1:0] parallel_o,
	input wire serial_i
);
	
	wire counter_run_w;
	wire counter_load_w;
	wire [$clog2(WORD_WIDTH)-1:0] count_w;
	
	counter_binary #(
		.WORD_WIDTH(WORD_WIDTH),
		.INCREMENT(1),
		.INITIAL_COUNT(WORD_WIDTH-1)
	) shifts_remaining (
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.up_down_i(1'b1),
		.run_i(counter_run_w),
		.load_i(counter_load_w),
		.load_count_i(WORD_WIDTH-2),
		.carry_in_i(1'b0),
		.carry_out_o(),
		.carries_o(),
		.overflow_o(),
		.count_o(count_w)
	);
	
	wire shifter_run_w;
	
	register_pipeline #(
		.WORD_WIDTH(1),
		.PIPE_DEPTH(WORD_WIDTH),
		.RESET_VALUES(0)
	) shift_register (
		.clk_i(clk_i),
		.clk_en_i(shifter_run_w),
		.rst_ni(rst_ni),
		.parallel_load_i(1'b0),
		.parallel_i(0),
		.parallel_o(parallel_o),
		.pipe_i(serial_i),
		.pipe_o()
	);
	
	wire handshake_done_w;
	
	assign parallel_valid_o = count_w == 0 && clk_en_i;
	assign handshake_done_w = parallel_valid_o && parallel_ready_i;
	assign counter_run_w = count_w != 0 && clk_en_i;
	assign counter_load_w = handshake_done_w;
	assign shifter_run_w = counter_run_w || counter_load_w;

endmodule