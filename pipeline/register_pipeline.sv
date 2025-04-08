module register_pipeline #(
	parameter WORD_WIDTH = 0,
	parameter PIPE_DEPTH = 0,
	parameter TOTAL_WIDTH = WORD_WIDTH * PIPE_DEPTH,
	parameter [TOTAL_WIDTH-1:0] RESET_VALUES = 0
) (
	input wire clk_i,
	input wire clk_en_i,
	input wire rst_ni,
	input wire parallel_load_i,
	input wire [TOTAL_WIDTH-1:0] parallel_i,
	output wire [TOTAL_WIDTH-1:0] parallel_o,
	input wire [WORD_WIDTH-1:0] pipe_i,
	output wire [WORD_WIDTH-1:0] pipe_o
);
	
	wire [WORD_WIDTH-1:0] pipe_stage_in_w [PIPE_DEPTH-1:0];
	wire [WORD_WIDTH-1:0] pipe_stage_out_w [PIPE_DEPTH-1:0];
	
	
	// index 0
	multiplexer #(
		.WORD_WIDTH(WORD_WIDTH),
		.ADDR_WIDTH(1),
		.INPUT_COUNT(2)
	) pipe_input_select (
		.sel_i(parallel_load_i),
		.words_i({parallel_i[0+:WORD_WIDTH], pipe_i}),
		.word_o(pipe_stage_in_w[0])
	);
	
	register #(
		.WORD_WIDTH(WORD_WIDTH),
		.RESET_VALUE(RESET_VALUES[0+:WORD_WIDTH])
	) pipe_stage (
		.clk_i(clk_i),
		.clk_en_i(clk_en_i),
		.rst_ni(rst_ni),
		.data_i(pipe_stage_in_w[0]),
		.data_o(pipe_stage_out_w[0])
	);
	
	assign parallel_o[0+:WORD_WIDTH] = pipe_stage_out_w[0];
	
	// generate loop
	generate
		genvar i;
		for(i = 1; i < PIPE_DEPTH; i = i + 1) begin: pipe_stages
			multiplexer #(
				.WORD_WIDTH(WORD_WIDTH),
				.ADDR_WIDTH(1),
				.INPUT_COUNT(2)
			) pipe_input_select (
				.sel_i(parallel_load_i),
				.words_i({parallel_i[i*WORD_WIDTH+:WORD_WIDTH], pipe_stage_out_w[i-1]}),
				.word_o(pipe_stage_in_w[i])
			);
			
			register #(
				.WORD_WIDTH(WORD_WIDTH),
				.RESET_VALUE(RESET_VALUES[i*WORD_WIDTH+:WORD_WIDTH])
			) pipe_stage (
				.clk_i(clk_i),
				.clk_en_i(clk_en_i),
				.rst_ni(rst_ni),
				.data_i(pipe_stage_in_w[i]),
				.data_o(pipe_stage_out_w[i])
			);
			
			assign parallel_o[i*WORD_WIDTH+:WORD_WIDTH] = pipe_stage_out_w[i];
		end
	endgenerate
	
	assign pipe_o = pipe_stage_out_w[PIPE_DEPTH-1];
endmodule