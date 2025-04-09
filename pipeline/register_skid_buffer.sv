module register_skid_buffer #(
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

	reg ready_r;
	// skid buffer
	reg buffer_valid_r;
	reg [DW-1:0] buffer_data_r;
	
	// cut ready
	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			ready_r <= 1'b1;
		end else begin
			if(clear_i) begin
				ready_r <= 1'b1;
			end else if(ready_i) begin
				ready_r <= 1'b1;
			end else if(valid_i) begin
				ready_r <= 1'b0;
			end
		end
	end
	
	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			buffer_data_r <= 0;
		end else begin
			if(clear_i) begin
				buffer_data_r <= 0;
			end else if(!ready_i && valid_i && ready_o) begin
				buffer_data_r <= data_i;
			end
		end
	end
	
	// this always block equals to below
	// assign buffer_valid_r = ~ready_o;
	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			buffer_valid_r <= 1'b0;
		end else begin
			if(clear_i) begin
				buffer_valid_r <= 1'b0;
			end else if(ready_i) begin
				buffer_valid_r <= 1'b0;
			end else if(!ready_i && valid_i && ready_o) begin
				buffer_valid_r <= 1'b1;
			end
		end
	end
	
	assign ready_o = ready_r;
	assign valid_o = ready_o ? valid_i : buffer_valid_r;
	assign data_o = ready_o ? data_i : buffer_data_r;

endmodule