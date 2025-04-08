module multiplexer #(
	parameter WORD_WIDTH = 0,
	parameter ADDR_WIDTH = 0,
	parameter INPUT_COUNT = 0,
	parameter TOTAL_WIDTH = WORD_WIDTH * INPUT_COUNT
) (
	input wire [ADDR_WIDTH-1:0] sel_i,
	input wire [TOTAL_WIDTH-1:0] words_i,
	output wire [WORD_WIDTH-1:0] word_o
);

	reg [WORD_WIDTH-1:0] word_r;
	
	always @(*) begin
		word_r = words_i[(sel_i * WORD_WIDTH) +: WORD_WIDTH];
	end
	
	assign word_o = word_r;
endmodule