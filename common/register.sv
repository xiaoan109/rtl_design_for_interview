module register #(
	parameter WORD_WIDTH = 0,
	parameter RESET_VALUE = 0
) (
	input wire clk_i,
	input wire clk_en_i,
	input wire rst_ni,
	input wire [WORD_WIDTH-1:0] data_i,
	output wire [WORD_WIDTH-1:0] data_o
);
	
	reg [WORD_WIDTH-1:0] data_r;
	
	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			data_r <= RESET_VALUE;
		end else if(clk_en_i) begin
			data_r <= data_i;
		end
	end
	
	assign data_o = data_r;

endmodule