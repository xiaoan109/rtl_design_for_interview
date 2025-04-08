module seq_det #(
	parameter DETECT_WIDTH = 5,
	parameter reg [DETECT_WIDTH-1:0] PATTERN = 5'b10110,
	parameter OVERLAPPING = 1
) (
	input wire clk_i,
	input wire rst_ni,
	input wire data_i,
	output wire detected_o
);

	reg [DETECT_WIDTH-1:0] SISO_DATA;
	generate
		if(OVERLAPPING == 1) begin : gen_overlap
			always @(posedge clk_i or negedge rst_ni) begin
				if(~rst_ni) begin
					SISO_DATA <= 0;
				end else begin
					SISO_DATA <= {SISO_DATA[DETECT_WIDTH-2:0], data_i};
				end
			end
			
			assign detected_o = (SISO_DATA == PATTERN);
		end else begin : gen_non_overlap
			reg [DETECT_WIDTH-1:0] SISO_FLAG;
			always @(posedge clk_i or negedge rst_ni) begin
				if(~rst_ni) begin
					SISO_DATA <= 0;
					SISO_FLAG <= 0;
				end else begin
					SISO_DATA <= {SISO_DATA[DETECT_WIDTH-2:0], data_i};
					SISO_FLAG <= {SISO_FLAG[DETECT_WIDTH-2:0], (({SISO_DATA[DETECT_WIDTH-2:0], data_i} == PATTERN) && ~|SISO_FLAG) ? 1'b1 : 1'b0};
				end
			end
			
			assign detected_o = SISO_FLAG[0];
		end
	endgenerate

endmodule