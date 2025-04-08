module stream_register #(
	parameter DW = 8
) (
	input wire clk_i,
	input wire rst_ni,
	input wire clear_i,
	input wire valid_i,
	output wire ready_o,
	input wire [DW-1:0] data_i,
	output wire valid_o,
	input wire ready_i,
	output wire [DW-1:0] data_o
);
	
	
	wire reg_ena_w;
	reg valid_r;
	reg [DW-1:0] data_r;
	assign ready_o = ready_i || ~valid_o;
	assign reg_ena_w = valid_i && ready_o;
	
	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			valid_r <= 1'b0;
		end else begin
			if(clear_i) begin
				valid_r <= 1'b0;
			end else if(ready_o) begin
				valid_r <= valid_i;
			end
		end
	end
	
	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			data_r <= 0;
		end else begin
			if(clear_i) begin
				data_r <= 0;
			end else if(reg_ena_w) begin
				data_r <= data_i;
			end
		end
	end
	
	assign valid_o = valid_r;
	assign data_o = data_r;


endmodule