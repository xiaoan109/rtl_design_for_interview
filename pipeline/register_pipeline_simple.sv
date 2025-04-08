module register_pipeline_simple #(
	parameter WORD_WIDTH = 0,
	parameter PIPE_DEPTH = -1
) (
	input wire clk_i,
	input wire clk_en_i,
	input wire rst_ni,
	input wire [WORD_WIDTH-1:0] pipe_i,
	output wire [WORD_WIDTH-1:0] pipe_o
);
	generate
		genvar i;
		if(PIPE_DEPTH == 0) begin
			assign pipe_o = pipe_i;
		end else if(PIPE_DEPTH > 0) begin
			wire [WORD_WIDTH-1:0] pipe_w [PIPE_DEPTH-1:0];
			register #(
				.WORD_WIDTH(WORD_WIDTH),
				.RESET_VALUE(0)
			) input_stage (
				.clk_i(clk_i),
				.clk_en_i(clk_en_i),
				.rst_ni(rst_ni),
				.data_i(pipe_i),
				.data_o(pipe_w[0])
			);
			
			for(i = 1; i < PIPE_DEPTH; i = i + 1) begin: pipe_stages
				register #(
					.WORD_WIDTH(WORD_WIDTH),
					.RESET_VALUE(0)
				) input_stage (
					.clk_i(clk_i),
					.clk_en_i(clk_en_i),
					.rst_ni(rst_ni),
					.data_i(pipe_w[i-1]),
					.data_o(pipe_w[i])
				);
			end
			assign pipe_o = pipe_w[PIPE_DEPTH-1];
			
		end
	endgenerate

endmodule